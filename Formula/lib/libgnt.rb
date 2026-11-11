class Libgnt < Formula
  desc "NCurses toolkit for creating text-mode graphical user interfaces"
  homepage "https://pidgin.im/"
  url "https://downloads.sourceforge.net/project/pidgin/libgnt/2.15.0/libgnt-2.15.0.tar.xz"
  sha256 "6dce3d4f2fb33c242d8223ddda5f1042f3dfb0ad7c395d4e33a73f92423a58a3"
  license "GPL-2.0-or-later"
  compatibility_version 1

  livecheck do
    url "https://sourceforge.net/projects/pidgin/rss?path=/libgnt"
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "5e2490de628cb45417e8e3020c4c12a5045c9b3b8aaf306465f16885fb051c05"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build

  depends_on "glib"
  depends_on "ncurses"

  uses_from_macos "libxml2"

  on_macos do
    depends_on "gettext"
  end

  deny_network_access!

  def install
    system "meson", "setup", "build", "-Ddoc=false", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <gnt/gnt.h>

      int main() {
          gnt_init();
          gnt_quit();

          return 0;
      }
    C

    flags = [
      "-I#{formula_opt_include("glib")}/glib-2.0",
      "-I#{formula_opt_lib("glib")}/glib-2.0/include",
      "-I#{include}",
      "-L#{lib}",
      "-L#{formula_opt_lib("glib")}",
      "-lgnt",
      "-lglib-2.0",
    ]
    system ENV.cc, "test.c", *flags, "-o", "test"
    system "./test"
  end
end
