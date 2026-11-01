class Mpfi < Formula
  desc "Multiple precision interval arithmetic library"
  homepage "https://perso.ens-lyon.fr/nathalie.revol/software.html"
  url "https://gitlab.inria.fr/mpfi/mpfi/-/archive/1.5.5/mpfi-1.5.5.tar.bz2"
  sha256 "4c5d0c43759ee3e2bd8e4ffce078e85e928925b8bea97206cdf1620b2225b463"
  license all_of: ["GPL-3.0-or-later", "LGPL-2.1-or-later"]
  compatibility_version 1
  head "https://gitlab.inria.fr/mpfi/mpfi.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "6246e3bbf679028e8e500b389ee291a436057ed713525a4b9143f0ee56b1436d"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gmp"
  depends_on "mpfr"

  deny_network_access!

  def install
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <mpfi.h>

      int main()
      {
        mpfi_t x;
        mpfi_init(x);
        mpfi_clear(x);
        return 0;
      }
    C

    system ENV.cc, "test.c", "-o", "test",
                   "-L#{lib}", "-lmpfi",
                   "-L#{Formula["mpfr"].lib}", "-lmpfr",
                   "-L#{Formula["gmp"].lib}", "-lgmp"
    system "./test"
  end
end
