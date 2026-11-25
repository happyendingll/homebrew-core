class Massdriver < Formula
  desc "Manage applications and infrastructure on Massdriver Cloud"
  homepage "https://www.massdriver.cloud/"
  url "https://github.com/massdriver-cloud/mass/archive/refs/tags/2.6.0.tar.gz"
  sha256 "6d3566c185a969a10aa776099c07103726d5b186cf789a7e48dd0709e73d6e0f"
  license "Apache-2.0"
  head "https://github.com/massdriver-cloud/mass.git", branch: "main"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "4f163fcfe79d929b56231030f59bb914013e6decf6b96090a6dc5b53ce3cd6e5"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/massdriver-cloud/mass/internal/version.version=#{version}
      -X github.com/massdriver-cloud/mass/internal/version.gitSHA=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"mass")

    generate_completions_from_executable(bin/"mass", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mass version")

    ENV["MASSDRIVER_ORGANIZATION_ID"] = "homebrew"
    ENV["MASSDRIVER_API_KEY"] = "test"
    output = shell_output("#{bin}/mass bundle build 2>&1", 1)
    assert_match "Error: open massdriver.yaml: no such file or directory", output
  end
end
