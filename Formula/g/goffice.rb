class Goffice < Formula
  desc "Gnumeric spreadsheet program"
  homepage "https://gitlab.gnome.org/GNOME/goffice"
  url "https://download.gnome.org/sources/goffice/0.10/goffice-0.10.62.tar.xz"
  sha256 "500eaff50628faa75adb3cd560236a4db498d9e7c52c036b78fa9a57f21805b3"
  license any_of: ["GPL-3.0-only", "GPL-2.0-only"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "4eb7c76ec9e82a0393fa98bdc6d3d7bd4d6c69f5a983001ee013a4df3fa647e0"
  end

  head do
    url "https://gitlab.gnome.org/GNOME/goffice.git", branch: "master"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gtk-doc" => :build
    depends_on "libtool" => :build
  end

  depends_on "gettext" => :build
  depends_on "intltool" => :build
  depends_on "pkgconf" => [:build, :test]

  depends_on "at-spi2-core"
  depends_on "cairo"
  depends_on "gdk-pixbuf"
  depends_on "glib"
  depends_on "gtk+3"
  depends_on "libgsf"
  depends_on "librsvg"
  depends_on "pango"

  uses_from_macos "perl" => :build
  uses_from_macos "python" => :build
  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  on_macos do
    depends_on "gettext"
    depends_on "harfbuzz"
  end

  on_linux do
    depends_on "perl-xml-parser" => :build
  end

  def install
    configure = build.head? ? "./autogen.sh" : "./configure"
    system configure, "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <goffice/goffice.h>
      int main() {
        libgoffice_init();
        libgoffice_shutdown();
        return 0;
      }
    C

    flags = shell_output("pkgconf --cflags --libs libgoffice-#{version.major_minor}").strip.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
