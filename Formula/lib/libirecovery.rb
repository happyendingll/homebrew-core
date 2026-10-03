class Libirecovery < Formula
  desc "Library and utility to talk to iBoot/iBSS via USB"
  homepage "https://www.libimobiledevice.org/"
  url "https://github.com/libimobiledevice/libirecovery/releases/download/1.3.1/libirecovery-1.3.1.tar.bz2"
  sha256 "28a3a521782063c8eb2ee5f4c0f38a517e023853edb55856052cdd7ac400381b"
  license "LGPL-2.1-only"
  revision 1
  head "https://github.com/libimobiledevice/libirecovery.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "f20de1a13f2767074bc445e69a7bf489ba3e143b8dc4d221e8e83d1b58ab534c"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "libimobiledevice-glue"

  on_macos do
    depends_on "libplist"
  end

  on_linux do
    depends_on "libusb"
    depends_on "readline"
  end

  def install
    configure = build.head? ? "./autogen.sh" : "./configure"

    args = ["--with-udevrulesdir=#{lib}/udev/rules.d"] if OS.linux?
    system configure, "--disable-silent-rules", *args, *std_configure_args
    system "make", "install"
  end

  test do
    assert_match "ERROR: Unable to connect to device", shell_output("#{bin}/irecovery -f nothing 2>&1", 255)
  end
end
