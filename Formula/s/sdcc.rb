class Sdcc < Formula
  desc "ANSI C compiler for Intel 8051, Maxim 80DS390, and Zilog Z80"
  homepage "https://sdcc.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/sdcc/sdcc/4.6.0/sdcc-src-4.6.0.tar.bz2"
  sha256 "5fd6a93e5997ce01756868fe35e441095cfb637894a80c262514a634094973b6"
  license all_of: [
    "GPL-2.0-or-later", # sdcc, sdcdb, ucsim
    "GPL-3.0-or-later", # sdcpp, sdas, sdld, sdbinutils
    :public_domain,     # packihx
    "Zlib",             # makebin
  ]
  revision 1
  head "https://svn.code.sf.net/p/sdcc/code/trunk/sdcc"

  livecheck do
    url :stable
    regex(%r{url=.*?/sdcc-src[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "53042cf597b2bc9a3c961b0d7721dcd5dda625fb25a61115d234be715fb73a54"
  end

  depends_on "boost" => :build
  depends_on "gputils"
  depends_on "readline"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  on_macos do
    depends_on "zstd"
  end

  on_system :linux, macos: :ventura_or_newer do
    depends_on "texinfo" => :build
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "./configure", "--disable-non-free", "--without-ccache", *std_configure_args
    system "make", "install"
    elisp.install bin.glob("*.el")
    # FIXME: sdbinutils prefixes every tool except the demangler, which clashes with `binutils`
    mv bin/"c++filt", bin/"sdc++filt"
  end

  test do
    (testpath/"test.c").write <<~C
      int main() {
        return 0;
      }
    C
    system bin/"sdcc", "-mz80", testpath/"test.c"
    assert_match "main()", shell_output("#{bin}/sdc++filt _Z4mainv")
    assert_path_exists testpath/"test.ihx"
  end
end
