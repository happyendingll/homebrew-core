class OsctrlMcp < Formula
  desc "Fast and efficient osquery management"
  homepage "https://docs.osctrl.net/components/osctrl-mcp/"
  url "https://github.com/jmpsec/osctrl/archive/refs/tags/v0.5.9.tar.gz"
  sha256 "2de1f3ba46cd9a82c0a40c9be7ad3cabccdda9fb16bd2d70c6ab113d21b145d8"
  license "MIT"
  head "https://github.com/jmpsec/osctrl.git", branch: "develop"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "754f5214c541761058b434be4031a8ae726e8633e452e91896a15cc515ae7962"
  end

  depends_on "go" => :build

  deny_network_access! :build

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/mcp"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/osctrl-mcp --version")

    output = shell_output("#{bin}/osctrl-mcp --api-url aaa 2>&1", 1)
    assert_match "no API token", output
  end
end
