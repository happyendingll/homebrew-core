class Ideviceinstaller < Formula
  desc "Tool for managing apps on iOS devices"
  homepage "https://libimobiledevice.org/"
  url "https://github.com/libimobiledevice/ideviceinstaller/releases/download/1.2.0/ideviceinstaller-1.2.0.tar.bz2"
  sha256 "26115288e50d003bbb7d23c05441c54ea69b255974303bfd44fef6943e042f94"
  license "GPL-2.0-or-later"
  revision 1
  head "https://github.com/libimobiledevice/ideviceinstaller.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "a52f6cfd7b8de41602e1b21b43c9ae097d92740f83c56914e2219f4ce50f8f42"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "libimobiledevice"
  depends_on "libplist"
  depends_on "libzip"

  def install
    configure = build.head? ? "./autogen.sh" : "./configure"
    system configure, *std_configure_args
    system "make", "install"
  end

  test do
    assert_match "Manage apps on iOS devices", shell_output("#{bin}/ideviceinstaller --help")
  end
end
