class Libirecovery < Formula
  desc "Library and utility to talk to iBoot/iBSS via USB"
  homepage "https://www.libimobiledevice.org/"
  url "https://github.com/libimobiledevice/libirecovery/releases/download/1.4.0/libirecovery-1.4.0.tar.bz2"
  sha256 "ea358430fdcedc00ae7d5764b3d03737f7345c91364fb91271bc6ceeee5d9cac"
  license "LGPL-2.1-only"
  head "https://github.com/libimobiledevice/libirecovery.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 sequoia: "e76e8068f87121806b4254b2eb126111a69131ac1c4c7213fbd14afab6d335d1"
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

  deny_network_access!

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
