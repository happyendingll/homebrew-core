class Gascity < Formula
  desc "Orchestration-builder SDK for multi-agent coding workflows"
  homepage "https://github.com/gastownhall/gascity"
  url "https://github.com/gastownhall/gascity/archive/refs/tags/v1.5.1.tar.gz"
  sha256 "ed81257ac3e7d1d3cf96036dfd7039350f5852bcd556f6842da6cb714e0022ab"
  license "MIT"
  head "https://github.com/gastownhall/gascity.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256                               arm64_golden_gate: "889a380a0d1d3b2b1a6732cfa62508764c5742aafdeb4f9bc8c648526fce3aae"
    sha256                               arm64_tahoe:       "5dc2c3f0a10543c8b92f11cb8d73a9e95c27f485d776c16b3c8267dbe1b4a153"
    sha256                               arm64_sequoia:     "84ef90e6923217a80311c872d1dc944e1ef2c77d97cc6154d47d0f9595bfcb40"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "cb27d63f0dc62e967a2e41cfc79709b95991b511a8788bd3f002a02efc2bd5e0"
    sha256 cellar: :any,                 x86_64_linux:      "396feec8ea86d147f16a7111ff064c8fc9306a5472ad380b303f92aa5714b624"
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

  conflicts_with "graphviz", because: "both install a `gc` binary"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}", output: bin/"gc"), "./cmd/gc"
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
