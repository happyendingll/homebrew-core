class Sngrep < Formula
  desc "Command-line tool for displaying SIP calls message flows"
  homepage "https://github.com/irontec/sngrep"
  url "https://github.com/irontec/sngrep/releases/download/v1.10.0/sngrep-1.10.0.tar.gz"
  sha256 "2a66d9b8b2a58f1a0486fe77760d23b30e3a98c7f2288a1fc8623826b6ebd5a2"
  license "GPL-3.0-or-later" => { with: "cryptsetup-OpenSSL-exception" }

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 sequoia: "38550ea19a747c090072a882c9031d5d4f4eb2942d14de5d6f14429476dbce7b"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkgconf" => :build

  depends_on "ncurses"
  depends_on "openssl@4"

  uses_from_macos "libpcap"

  deny_network_access!

  def install
    ENV.append_to_cflags "-I#{formula_opt_include("ncurses")}/ncursesw" if OS.linux?

    system "./bootstrap.sh"
    system "./configure", "--disable-silent-rules",
                          "--with-openssl",
                          *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"sngrep", "-NI", test_fixtures("test.pcap")
  end
end
