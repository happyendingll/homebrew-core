class Libpcap < Formula
  desc "Portable library for network traffic capture"
  homepage "https://www.tcpdump.org/"
  url "https://www.tcpdump.org/release/libpcap-1.11.1.tar.gz"
  sha256 "7985b1d20ff82c1e384115038046e0b15034648c6f45c92e08601d4ee1b369ed"
  license "BSD-3-Clause"
  compatibility_version 1
  head "https://github.com/the-tcpdump-group/libpcap.git", branch: "master"

  livecheck do
    url "https://www.tcpdump.org/release/"
    regex(/href=.*?libpcap[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "446eb71ea7a7ad5af9ba6036d581b6fd005d7e2770214c7285c7ca0c177dff19"
  end

  keg_only :provided_by_macos

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  deny_network_access!

  def install
    # Exclude unrecognized options
    std_args = std_configure_args.reject { |s| s["--disable-debug"] || s["--disable-dependency-tracking"] }
    system "./configure", "--enable-ipv6", "--disable-universal", *std_args
    system "make", "install"
  end

  test do
    assert_match "lpcap", shell_output("#{bin}/pcap-config --libs")
  end
end
