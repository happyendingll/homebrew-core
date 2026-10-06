class QalculateGtk < Formula
  desc "Multi-purpose desktop calculator"
  homepage "https://qalculate.github.io/"
  url "https://github.com/Qalculate/qalculate-gtk/releases/download/v5.13.0/qalculate-gtk-5.13.0.tar.gz"
  sha256 "2c6c9711fcd1bebb09b27c39dda9bd6e0a86b1b17b1538b4e9a1c711e435a830"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "00ad62b3f23fe191379336fb9da92d1e8886cbbac362ea9f5fa9ba7bda32f869"
  end

  depends_on "gettext" => :build
  depends_on "pkgconf" => :build

  depends_on "adwaita-icon-theme"
  depends_on "cairo"
  depends_on "gdk-pixbuf"
  depends_on "glib"
  depends_on "gtk+3"
  depends_on "libqalculate"
  depends_on "pango"

  on_macos do
    depends_on "at-spi2-core"
    depends_on "gettext"
    depends_on "gtk-mac-integration"
    depends_on "harfbuzz"
  end

  def install
    if OS.mac?
      ENV.append_to_cflags "-I#{formula_opt_include("gtk-mac-integration")/"gtkmacintegration"}"
      ENV.append "LDFLAGS", "-L#{formula_opt_lib("gtk-mac-integration")} -lgtkmacintegration-gtk3"
    end
    ENV.prepend_path "PERL5LIB", formula_opt_libexec("perl-xml-parser")/"lib/perl5" unless OS.mac?

    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"qalculate-gtk", "-v"
  end
end
