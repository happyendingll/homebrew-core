class Hspell < Formula
  desc "Free Hebrew linguistic project"
  homepage "https://hspell.sourceforge.net/"
  url "https://hspell.sourceforge.net/hspell-1.4.tar.gz"
  sha256 "7310f5d58740d21d6d215c1179658602ef7da97a816bc1497c8764be97aabea3"
  license "AGPL-3.0-only"

  livecheck do
    url "https://hspell.sourceforge.net/download.html"
    regex(/href=.*?hspell[._-]v?(\d+(?:\.\d+)+)\.t/i)
    strategy :page_match
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "83eaec560e16155db2c3927318c9273fc42774a7a5724d0bb2313d65c376f76a"
  end

  depends_on "autoconf" => :build

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # hspell was built for linux and compiles a .so shared library, to comply with macOS
  # standards this patch creates a .dylib instead
  patch :p0 do
    on_macos do
      file "Patches/hspell/1.3.patch"
    end
  end

  def install
    ENV.deparallelize

    # The build scripts rely on "." being in @INC which was disabled by default in perl 5.26
    ENV["PERL_USE_UNSAFE_INC"] = "1"

    # C23 rejects the K&R-style function definitions in the bundled tclHash.c
    ENV.append_to_cflags "-std=gnu17"

    # autoconf needs to pick up on the patched configure.in and create a new ./configure
    # script
    system "autoconf"

    system "./configure", "--prefix=#{prefix}",
                          "--enable-shared",
                          "--enable-linginfo"
    system "make", "dolinginfo"
    system "make", "install"
  end

  test do
    File.open("test.txt", "w:ISO8859-8") do |f|
      f.write "שלום"
    end
    system bin/"hspell", "-l", "test.txt"
  end
end
