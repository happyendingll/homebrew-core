class Libint < Formula
  desc "Library for computing electron repulsion integrals efficiently"
  homepage "https://github.com/evaleev/libint"
  url "https://github.com/evaleev/libint/archive/refs/tags/v2.14.1.tar.gz"
  sha256 "d40f15a1e3c271d5520ec06028f76152fa9ed796f7fc27fd36ee4f93b940605a"
  # The generator is GPLv3 but it doesn't impact the license of packaged library
  license "LGPL-3.0-only"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "71adc709a8b3ae8ecded5f000b8a278b62ed9124cbc1245b4fbcccff480c6a57"
  end

  depends_on "cmake" => :build
  depends_on "gmp" => :build
  depends_on "pkgconf" => :build

  depends_on "boost" => :no_linkage
  depends_on "eigen" => :no_linkage
  depends_on "gcc" # for libgfortran

  uses_from_macos "python" => :build

  deny_network_access!

  def install
    args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DLIBINT2_ENABLE_ERI=1
      -DLIBINT2_ENABLE_ERI2=1
      -DLIBINT2_ENABLE_ERI3=1
      -DLIBINT2_ENABLE_FORTRAN=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "export/tests/hartree-fock/hartree-fock.cc"
    pkgshare.install "export/tests/hartree-fock/h2o.xyz"
  end

  test do
    system ENV.cxx, "-std=c++14", pkgshare/"hartree-fock.cc", "-o", "hartree-fock",
                    "-I#{formula_opt_include("eigen")}/eigen3", "-L#{lib}", "-lint2"
    system "./hartree-fock", pkgshare/"h2o.xyz"
  end
end
