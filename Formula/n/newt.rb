class Newt < Formula
  desc "Library for color text mode, widget based user interfaces"
  homepage "https://gitlab.com/newt-ui/newt"
  url "https://gitlab.com/newt-ui/newt/-/releases/0.52.25/downloads/newt-0.52.25.tar.gz"
  sha256 "ef0ca9ee27850d1a5c863bb7ff9aa08096c9ed312ece9087b30f3a426828de82"
  license "LGPL-2.0-or-later"
  revision 2

  livecheck do
    url :head
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "73d1b1370b434ca6b1d54f337e4c5ecab68c0ddaacab6ba35efa0b5637ac20e2"
  end

  head do
    url "https://gitlab.com/newt-ui/newt.git", branch: "master"

    depends_on "autoconf" => :build

    on_linux do
      depends_on "gettext" => :build
    end
  end

  depends_on "popt"
  depends_on "python@3.15"
  depends_on "s-lang"

  on_macos do
    depends_on "gettext"
  end

  def install
    system "./autogen.sh" if build.head?

    inreplace "Makefile.in" do |s|
      if OS.mac?
        # name libraries correctly
        # https://bugzilla.redhat.com/show_bug.cgi?id=1192285
        s.gsub! "libnewt.$(SOEXT).$(SONAME)", "libnewt.$(SONAME).dylib"
        s.gsub! "libnewt.$(SOEXT).$(VERSION)", "libnewt.$(VERSION).dylib"

        # don't link to libpython.dylib
        # causes https://github.com/Homebrew/homebrew/issues/30252
        # https://bugzilla.redhat.com/show_bug.cgi?id=1192286
        s.gsub! "`$$pyconfig --ldflags --embed || $$pyconfig --ldflags`", '"-undefined dynamic_lookup"'
      end

      # install python modules in Cellar rather than global site-packages
      s.gsub! "`$$ver -c \"import sysconfig; print(sysconfig.get_path('platlib'))\"`",
              (prefix/Language::Python.site_packages(python3)).to_s
    end

    # The Makefile also uses the `--with-python` value as a build directory name, so it must not be a path
    system "./configure", "--prefix=#{prefix}", "--without-tcl", "--with-python=#{python3.basename}"
    system "make", "install"
  end

  test do
    ENV["TERM"] = "xterm"
    system python3, "-c", "import snack"

    (testpath/"test.c").write <<~C
      #import <newt.h>
      int main() {
        newtInit();
        newtFinished();
      }
    C
    system ENV.cc, "test.c", "-o", "test", "-L#{lib}", "-lnewt"
    system "./test"
  end
end
