class Sundials < Formula
  desc "Nonlinear and differential/algebraic equations solver"
  homepage "https://computing.llnl.gov/projects/sundials"
  url "https://github.com/llnl/sundials/releases/download/v7.9.0/sundials-7.9.0.tar.gz"
  sha256 "13f898a27b48fe3449483f9e438a800ed545abf93bc2e2ceec2d1e00ae8db5ef"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "1bdd3d16ad4661b5556dd6f9d9623621de5dbb118fd4649ea36697a7c9259e99"
  end

  depends_on "cmake" => :build
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "suite-sparse"

  def install
    args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DENABLE_KLU=ON
      -DENABLE_LAPACK=ON
      -DENABLE_MPI=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Only keep one example for testing purposes
    (pkgshare/"examples").install [
      "test/unit_tests/nvector/test_nvector.c",
      "test/unit_tests/nvector/test_nvector.h",
      "test/unit_tests/nvector/serial/test_nvector_serial.c",
    ]
    rm_r(prefix/"examples")
  end

  test do
    cp Dir[pkgshare/"examples/*"], testpath
    args = %W[
      -I#{include}
      -L#{lib}
      -lsundials_core
      -lsundials_nvecserial
      -lmpi
      -lm
    ]

    args += ["-I#{formula_opt_include("open-mpi")}", "-L#{formula_opt_lib("open-mpi")}"] if OS.mac?

    system ENV.cc, "test_nvector.c", "test_nvector_serial.c", "-o", "test", *args

    assert_match "SUCCESS: NVector module passed all tests", shell_output("./test 42 0")
  end
end
