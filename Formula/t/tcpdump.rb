class Tcpdump < Formula
  desc "Command-line packet analyzer"
  homepage "https://www.tcpdump.org/"
  url "https://www.tcpdump.org/release/tcpdump-4.99.7.tar.gz"
  sha256 "8be364e28d3b745ef1459b385cd2f4bc0e1ebad7a5d2ebdf70071d6c9b5b9a54"
  license "BSD-3-Clause"
  head "https://github.com/the-tcpdump-group/tcpdump.git", branch: "master"

  livecheck do
    url "https://www.tcpdump.org/release/"
    regex(/href=.*?tcpdump[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "77c23256e68732f0bee6deef895cc4bd5e7450f278e7f7e733bbd52c423fc5e8"
  end

  depends_on "libpcap"
  depends_on "openssl@4"

  def install
    system "./configure", "--disable-smb",
                          "--disable-universal",
                          "--with-crypto=#{formula_opt_prefix("openssl@4")}",
                          *std_configure_args
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/tcpdump --help 2>&1")
    assert_match "tcpdump version #{version}", output
    assert_match "libpcap version #{Formula["libpcap"].version}", output
    assert_match "OpenSSL #{Formula["openssl@4"].version}", output

    match = if OS.mac?
      "tcpdump: en0: (cannot open BPF device) /dev/bpf0: Operation not permitted"
    else
      "tcpdump: eth0: You don't have permission to perform this capture on that device"
    end
    assert_match match, shell_output("#{bin}/tcpdump ipv6 2>&1", 1)
  end
end
