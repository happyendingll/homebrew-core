class Ifopt < Formula
  desc "Light-weight C++ Interface to Nonlinear Programming Solvers"
  homepage "https://wiki.ros.org/ifopt"
  url "https://github.com/ethz-adrl/ifopt/archive/refs/tags/2.1.4.tar.gz"
  sha256 "da38f91a282f3ed305db163954c37d999b6e95f5d2c913a63bae3fef9ffb3a37"
  license "BSD-3-Clause"
  revision 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "cb17dca285219498c5437153a6b85ad2d0131e3e84f2b3b6e3b32c6f23365a6b"
  end

  depends_on "cmake" => :build

  depends_on "pkgconf" => :build
  depends_on "eigen"
  depends_on "ipopt"

  # Backport support for eigen 5.0.0
  patch do
    url "https://github.com/ethz-adrl/ifopt/commit/deb3209d5e34cdaa896c7432f6ee1138148ddfda.patch?full_index=1"
    sha256 "95e1ee352d1842811b2e015a78be304bfce0af867f8233f7e5e7e94aa01aae2d"
    type :backport
    resolves "https://github.com/ethz-adrl/ifopt/pull/110"
  end

  # Add missing `<iostream>` include for newer libc++
  patch do
    url "https://github.com/ethz-adrl/ifopt/commit/ca908c2f5e372b5ba9dad3573be6dd156a39d28a.patch?full_index=1"
    sha256 "15c9b47faecdfac311d9b5a67ad008c8d5a96cc5b64407a6448c909f7ec6a267"
    type :unofficial
    resolves "https://github.com/ethz-adrl/ifopt/pull/112"
  end

  deny_network_access!
  def install
    system "cmake", "-S", ".", "-B", "build", "-DCMAKE_POLICY_VERSION_MINIMUM=3.5", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    pkgshare.install "ifopt_ipopt/test"
  end

  test do
    cp pkgshare/"test/ex_test_ipopt.cc", "test.cpp"
    system ENV.cxx, "-std=c++14", "test.cpp", "-o", "test",
                    "-I#{formula_opt_include("eigen")}/eigen3",
                    "-L#{lib}", "-lifopt_core", "-lifopt_ipopt"
    assert_match "Optimal Solution Found", shell_output("./test")
  end
end
