class Range2cidr < Formula
  desc "Converts IP ranges to CIDRs"
  homepage "https://ipinfo.io"
  url "https://github.com/ipinfo/cli/archive/refs/tags/range2cidr-3.3.3.tar.gz"
  sha256 "bcf717e779d72f5b1ee01d808d6c86dfa5d9431ab786391c103a19cf3753948d"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^range2cidr[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "1d1aa0dee0dd8e58a289f90dfcf111112b906a560cebc6c871342c57f15d9009"
  end

  depends_on "go" => :build

  deny_network_access!

  def install
    system "go", "build", *std_go_args, "./range2cidr"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/range2cidr --version").chomp
    assert_equal "1.1.1.0/30", shell_output("#{bin}/range2cidr 1.1.1.0-1.1.1.3").chomp
    assert_equal "0.0.0.0/0", shell_output("#{bin}/range2cidr 0.0.0.0-255.255.255.255").chomp
    assert_equal "1.1.1.0/31\n1.1.1.2/32", shell_output("#{bin}/range2cidr 1.1.1.0-1.1.1.2").chomp
  end
end
