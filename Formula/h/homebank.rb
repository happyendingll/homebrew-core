class Homebank < Formula
  desc "Manage your personal accounts at home"
  homepage "https://www.gethomebank.org/en/index.php"
  url "https://www.gethomebank.org/public/sources/homebank-5.10.3.tar.gz"
  sha256 "574de504cceafdb6138ffa2e03be567ad66b8a2ceaef3434e07ca695e82dd9e3"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://www.gethomebank.org/public/sources/"
    regex(/href=.*?homebank[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "7cf76ce20fbf200ce4fc207460a63f052f0baf1014bc0e0eaa97bf9567327c0b"
  end

  depends_on "gettext" => :build
  depends_on "intltool" => :build
  depends_on "pkgconf" => :build

  depends_on "adwaita-icon-theme"
  depends_on "cairo"
  depends_on "gdk-pixbuf"
  depends_on "glib"
  depends_on "gtk+3"
  depends_on "hicolor-icon-theme"
  depends_on "libofx"
  depends_on "libsoup"
  depends_on "pango"

  uses_from_macos "perl" => :build

  on_macos do
    depends_on "at-spi2-core"
    depends_on "gettext"
    depends_on "harfbuzz"
  end

  on_linux do
    depends_on "perl-xml-parser" => :build
  end

  def install
    system "./configure", "--with-ofx", *std_configure_args
    system "make", "install"
  end

  test do
    # homebank is a GUI application
    system bin/"homebank", "--help"
  end
end
