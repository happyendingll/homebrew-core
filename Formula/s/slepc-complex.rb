class SlepcComplex < Formula
  desc "Scalable Library for Eigenvalue Problem Computations (complex)"
  homepage "https://slepc.upv.es"
  url "https://slepc.upv.es/download/distrib/slepc-3.25.2.tar.gz"
  sha256 "65795612fd50efd77d151bb884b0075429fe12c532963e38081988a5ed6efbd5"
  license "BSD-2-Clause"

  livecheck do
    formula "slepc"
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "83eb0ad3385f7c4843906daee8741d819fce4514137c51b9348a8556497775bd"
  end

  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "petsc-complex"
  depends_on "scalapack"

  uses_from_macos "python" => :build

  on_macos do
    depends_on "fftw"
    depends_on "gcc"
    depends_on "hdf5-mpi"
    depends_on "metis"
  end

  conflicts_with "slepc", because: "slepc must be installed with either real or complex support, not both"

  def install
    ENV["PETSC_DIR"] = Formula["petsc-complex"].prefix.realpath
    ENV["SLEPC_DIR"] = buildpath

    # This is not an autoconf script so cannot use `std_configure_args`
    system "./configure", "--prefix=#{prefix}"
    system "make", "all"
    system "make", "install", "PYTHON=#{which("python3")}"
  end

  test do
    pform = "petsc-complex"
    flags = %W[-I#{include} -L#{lib} -lslepc -I#{formula_opt_include(pform)} -L#{formula_opt_lib(pform)} -lpetsc]
    flags << "-Wl,-rpath,#{lib},-rpath,#{formula_opt_lib(pform)}" if OS.linux?
    system "mpicc", pkgshare/"../slepc/examples/src/eps/tutorials/ex2.c", "-o", "test", *flags
    output = shell_output("./test -terse")
    # This SLEPc example prints several lines of output. The 7th line contains
    # a specific message if everything went well
    line = output.lines.at(-3)
    assert_match "All requested eigenvalues computed up to the required tolerance:", line
  end
end
