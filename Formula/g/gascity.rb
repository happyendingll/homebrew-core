class Gascity < Formula
  desc "Orchestration-builder SDK for multi-agent coding workflows"
  homepage "https://github.com/gastownhall/gascity"
  url "https://github.com/gastownhall/gascity/archive/refs/tags/v1.4.2.tar.gz"
  sha256 "98a4cc61249e7277357b1dd6adf526d64bdf312472f8c5568126c4d586d56d59"
  license "MIT"
  head "https://github.com/gastownhall/gascity.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "d4ee97f0cb71a4eab9a118be71e0065ab7c6801fa8edc5f0a83c0735ffaf2be5"
  end

  depends_on "go" => :build
  depends_on "beads"
  depends_on "dolt"
  depends_on "icu4c@78"
  depends_on "jq"
  depends_on "tmux"

  on_macos do
    depends_on "flock"
  end

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    # TODO: Remove http2legacy tag when Gascity works without it in Go 1.27 (in release > 1.4.1?)
    # ref: https://github.com/gastownhall/gascity/pull/5030
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}", tags: "http2legacy", output: bin/"gc"), "./cmd/gc"
  end

  test do
    (testpath/"city-template.toml").write <<~TOML
      [workspace]
      name = "brew-test"

      [beads]
      provider = "file"
    TOML

    ENV["GC_HOME"] = testpath/".gc-home"
    city = testpath/"brew-city"

    output = shell_output("#{bin}/gc init --skip-provider-readiness --file city-template.toml #{city} 2>&1", 1)
    assert_match "Initialized city \"brew-city\"", output
    assert_path_exists city/"city.toml"
    assert_path_exists city/"pack.toml"
    assert_path_exists city/".gc/beads.json"
    assert_match "name = \"brew-city\"", (city/".gc/site.toml").read
    assert_match "provider = \"file\"", (city/"city.toml").read
  end
end
