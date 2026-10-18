class Libxpm < Formula
  desc "X.Org: X Pixmap (XPM) image file format library"
  homepage "https://www.x.org/"
  url "https://xorg.freedesktop.org/archive/individual/lib/libXpm-3.5.20.tar.gz"
  sha256 "736704d843459abbf769560ff8e443a5de4e6023082e7086c9d195253ada17ff"
  license "MIT"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "066b7cc447df337b39f5be2fd7a4e39d1835504b6616004f98015b777a29e91a"
  end

  depends_on "gettext" => :build
  depends_on "pkgconf" => :build
  depends_on "libx11"

  on_macos do
    depends_on "gettext"
  end

  def install
    args = %W[
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --disable-open-zfile
      --disable-silent-rules
      --disable-stat-zfile
    ]

    system "./configure", *args, *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include "X11/Xlib.h"
      #include "X11/xpm.h"

      int main(int argc, char* argv[]) {
        XpmColor color;
        return 0;
      }
    C
    system ENV.cc, "test.c"
    assert_equal 0, $CHILD_STATUS.exitstatus
  end
end
