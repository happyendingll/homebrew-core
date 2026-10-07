class Sngrep < Formula
  desc "Command-line tool for displaying SIP calls message flows"
  homepage "https://github.com/irontec/sngrep"
  url "https://github.com/irontec/sngrep/releases/download/v1.9.0/sngrep-1.9.0.tar.gz"
  sha256 "db1d45a27c5682a83ac9caedbca9a0af530c6da744b645d3f9b336d7ad2fc6a9"
  license "GPL-3.0-or-later" => { with: "cryptsetup-OpenSSL-exception" }

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "3d842f15351458e19eb55b9823eac60eb171810a968c65ade7e91daf367aca4c"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkgconf" => :build

  depends_on "ncurses"
  depends_on "openssl@4"

  uses_from_macos "libpcap"

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
