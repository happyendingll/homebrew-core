class Nextdns < Formula
  desc "CLI for NextDNS's DNS-over-HTTPS (DoH)"
  homepage "https://nextdns.io"
  url "https://github.com/nextdns/nextdns/archive/refs/tags/v1.50.2.tar.gz"
  sha256 "46ab8b64c36bb1db8fe6cd3b6ded9fbbd2af7c3ab4960c01e566ff2969fe97ee"
  license "MIT"
  head "https://github.com/nextdns/nextdns.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "005ea933e3e266e813fc0130b5bcb9bd75e4c24bb2d02540f8c7545b8cfa6ec1"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nextdns version")

    # Requires root to start
    output = if OS.mac?
      "Error: permission denied"
    else
      "Error: service nextdns start: exit status 1: nextdns: unrecognized service"
    end
    assert_match output, shell_output("#{bin}/nextdns start 2>&1", 1)
  end
end
