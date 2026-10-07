class Qrupdate < Formula
  desc "Fast updates of QR and Cholesky decompositions"
  homepage "https://gitlab.mpi-magdeburg.mpg.de/koehlerm/qrupdate-ng"
  url "https://gitlab.mpi-magdeburg.mpg.de/koehlerm/qrupdate-ng/-/archive/v1.3.0/qrupdate-ng-v1.3.0.tar.bz2"
  sha256 "a9bfa9b7dba580859babd89d04e31cfd289e7536b387c17be73bb5d1179273c4"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "e6f085568a030a7c3354e054fd249bc7b449f625448ecef6779319742583e14a"
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
