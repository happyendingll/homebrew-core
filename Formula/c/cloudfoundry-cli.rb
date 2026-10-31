class CloudfoundryCli < Formula
  desc "Official command-line client for Cloud Foundry"
  homepage "https://docs.cloudfoundry.org/cf-cli"
  url "https://github.com/cloudfoundry/cli/archive/refs/tags/v8.19.1.tar.gz"
  sha256 "b8a84d34a355dca188ef546e51d374f54f1aa82c0165bdb5e8d7ad7ee15da774"
  license "Apache-2.0"
  head "https://github.com/cloudfoundry/cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?((?!9\.9\.9)\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "8f83c49cd3e3c119acc0ccbd218c4c23f8fc6f86a06f7c502b402f3e16be7939"
  end

  depends_on "go" => :build

  conflicts_with "cf", because: "both install `cf` binaries"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X code.cloudfoundry.org/cli/v8/version.binaryVersion=#{version}
      -X code.cloudfoundry.org/cli/v8/version.binarySHA=#{tap.user}
      -X code.cloudfoundry.org/cli/v8/version.binaryBuildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"cf")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cf --version")

    expected = OS.linux? ? "Request error" : "lookup brew: no such host"
    assert_match expected, shell_output("#{bin}/cf login -a brew 2>&1", 1)
  end
end
