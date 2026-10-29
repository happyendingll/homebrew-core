class Lmfit < Formula
  desc "C library for Levenberg-Marquardt minimization and least-squares fitting"
  homepage "https://jugit.fz-juelich.de/mlz/lib/lmfit"
  url "https://jugit.fz-juelich.de/mlz/lib/lmfit/-/archive/v11.0.1/lmfit-v11.0.1.tar.bz2"
  sha256 "f4bdadcf959261c7dfc93402012493ae2ff307caed3418badde202a59a680d18"
  license "BSD-2-Clause"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "b1f88cbd8d236de9bde339e7c18d30b0b63fcb16a36cde15d8a3482555ae200c"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "demo/curve1.c"
  end

  test do
    system ENV.cc, pkgshare/"curve1.c", "-I#{include}", "-L#{lib}", "-llmfit", "-o", "test"
    assert_match "converged  (the relative error in the sum of squares is at most tol)", shell_output("./test")
  end
end
