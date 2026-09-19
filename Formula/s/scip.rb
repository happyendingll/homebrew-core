class Scip < Formula
  desc "Solver for mixed integer programming and mixed integer nonlinear programming"
  homepage "https://scipopt.org", browsed: "2026-09-18"
  url "https://scipopt.org/download/release/scip-10.1.0.tgz"
  sha256 "fe8cfd15a03970ef45156ed56c6a4382485bd095e0e99cf7d7db87cdf8d47304"
  license "Apache-2.0"
  compatibility_version 1

  livecheck do
    url "https://github.com/scipopt/scip"
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "ff41b3995c191f1b5af32b3bf35d5c935c62c0c35eeeb00b8f68d40b3d730f78"
  end

  depends_on "cmake" => :build
  depends_on "papilo" => :build # for static libraries
  depends_on "soplex" => :build # for static libraries
  depends_on "cppad" => :no_linkage
  depends_on "gcc" # for gfortran
  depends_on "gmp"
  depends_on "ipopt"
  depends_on "mpfr"
  depends_on "openblas"
  depends_on "readline"
  depends_on "tbb"

  on_macos do
    depends_on "boost"
  end

  on_linux do
    depends_on "boost" => :no_linkage
    depends_on "zlib-ng-compat"
  end

  def install
    system "cmake", "-S", ".", "-B", "build", "-DZIMPL=OFF", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "check/instances/MIP/enigma.mps"
    pkgshare.install "check/instances/MINLP/gastrans.nl"
    pkgshare.install "check/instances/MIPEX/flugpl_rational.mps"
  end

  test do
    expected = "problem is solved [optimal solution found]"
    assert_match expected, shell_output("#{bin}/scip -f #{pkgshare}/enigma.mps")
    assert_match expected, shell_output("#{bin}/scip -f #{pkgshare}/gastrans.nl")

    command = "set exact enable TRUE read #{pkgshare}/flugpl_rational.mps optimize quit"
    assert_match expected, shell_output("#{bin}/scip -c \"#{command}\"")
  end
end
