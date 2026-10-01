class Gnumeric < Formula
  desc "GNOME Spreadsheet Application"
  homepage "https://projects.gnome.org/gnumeric/"
  url "https://download.gnome.org/sources/gnumeric/1.12/gnumeric-1.12.62.tar.xz"
  sha256 "89331121321b9bad72d37af5a6d13a0a636f0fbb0880f0ea1f2cf8b7ab9ae631"
  license any_of: ["GPL-3.0-only", "GPL-2.0-only"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "8a989e89e0b00eea33494bdf9bd032c77e97023b353903ced42a12db4a93423c"
  end

  depends_on "gettext" => :build
  depends_on "intltool" => :build
  depends_on "itstool" => :build
  depends_on "pkgconf" => :build

  depends_on "adwaita-icon-theme"
  depends_on "at-spi2-core"
  depends_on "cairo"
  depends_on "fribidi"
  depends_on "gdk-pixbuf"
  depends_on "glib"
  depends_on "goffice"
  depends_on "gtk+3"
  depends_on "libgsf"
  depends_on "libxml2"
  depends_on "pango"

  uses_from_macos "bison" => :build
  uses_from_macos "python" => :build
  uses_from_macos "perl"

  on_macos do
    depends_on "gettext"
    depends_on "harfbuzz"
  end

  on_linux do
    depends_on "perl-xml-parser" => :build
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    # ensures that the files remain within the keg
    inreplace "component/Makefile.in",
              "GOFFICE_PLUGINS_DIR = @GOFFICE_PLUGINS_DIR@",
              "GOFFICE_PLUGINS_DIR = @libdir@/goffice/@GOFFICE_API_VER@/plugins/gnumeric"

    system "./configure", "--disable-schemas-compile",
                          "--disable-silent-rules",
                          *std_configure_args
    system "make", "install"
  end

  post_install_steps do
    compile_gsettings_schemas
  end

  test do
    system bin/"gnumeric", "--version"
  end
end
