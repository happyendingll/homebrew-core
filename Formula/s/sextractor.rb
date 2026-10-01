class Sextractor < Formula
  desc "Extract catalogs of sources from astronomical images"
  homepage "https://www.astromatic.net/software/sextractor/"
  url "https://github.com/astromatic/sextractor/archive/refs/tags/2.29.0.tar.gz"
  sha256 "f260886b1609f3a3dbe82ea14152761ed0434bc37631be4121137fee36025111"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "e63f15e1fe8a88a51e25034d08c3bf684d5ae6cc9f33c0ee87e57af48cfd6dec"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "cfitsio"
  depends_on "fftw"
  depends_on "openblas"

  # Backport for C23

  def install
    # Allow OpenBLAS header migration to subdirectory. Can remove once done
    openblas_incdir = formula_opt_include("openblas")/"openblas"
    openblas_incdir = formula_opt_include("openblas") unless openblas_incdir.exist?

    system "./autogen.sh"
    system "./configure", "--disable-silent-rules",
                          "--enable-openblas",
                          "--with-openblas-libdir=#{formula_opt_lib("openblas")}",
                          "--with-openblas-incdir=#{openblas_incdir}",
                          *std_configure_args
    system "make", "install"
    # Remove references to Homebrew shims
    rm Dir["tests/Makefile*"]
    pkgshare.install "tests"
  end

  test do
    cp_r Dir[pkgshare/"tests/*"], testpath
    system bin/"sex", "galaxies.fits", "-WEIGHT_IMAGE", "galaxies.weight.fits", "-CATALOG_NAME", "galaxies.cat"
    assert_path_exists testpath/"galaxies.cat", "Failed to create galaxies.cat"
  end
end
