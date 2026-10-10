class Qrupdate < Formula
  desc "Fast updates of QR and Cholesky decompositions"
  homepage "https://gitlab.mpi-magdeburg.mpg.de/koehlerm/qrupdate-ng"
  url "https://gitlab.mpi-magdeburg.mpg.de/koehlerm/qrupdate-ng/-/archive/v1.3.1/qrupdate-ng-v1.3.1.tar.bz2"
  sha256 "3877a52ff7bedd1edd746fed82f8347a8d1c4f48e59ebfbde7841eea79db87ee"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "1b3801ff23fc6c5aa469380ca4f8a8286739caef5e1d9e5bcf3950a9aeafb5d2"
  end

  depends_on "cmake" => :build
  depends_on "gcc" # for gfortran
  depends_on "openblas"

  deny_network_access!

  def install
    ENV.fortran

    # CMake's Fortran/C interface probe requires matching GCC LTO versions.
    ENV.method("gcc-#{Formula["gcc"].version.major}").call if OS.linux?

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    pkgshare.install "test/tch1dn.f90", "test/utils.f90"
  end

  test do
    system "gfortran", "-o", "test", pkgshare/"tch1dn.f90", pkgshare/"utils.f90",
                       "-fallow-argument-mismatch",
                       "-I#{include}/qrupdate",
                       "-L#{lib}", "-lqrupdate",
                       "-L#{formula_opt_lib("openblas")}", "-lopenblas"
    assert_match "PASSED   4     FAILED   0", shell_output("./test")
  end
end
