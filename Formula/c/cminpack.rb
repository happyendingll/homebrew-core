class Cminpack < Formula
  desc "Solves nonlinear equations and nonlinear least squares problems"
  homepage "http://devernay.free.fr/hacks/cminpack/cminpack.html"
  url "https://github.com/devernay/cminpack/archive/refs/tags/v1.3.15.tar.gz"
  sha256 "4bcc2fb514809eaa7bfecf2f2f663f3f0988a425ff64615316f5c4ed68757b97"
  license "Minpack"
  compatibility_version 1
  head "https://github.com/devernay/cminpack.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "45b88cab3ba1c67a76578d491bda1e838d8b5ada402d1041bdf9b4277e64acae"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON
      -DCMINPACK_LIB_INSTALL_DIR=lib
      -DBUILD_EXAMPLES=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    man3.install Dir["docs/*.3"]
    doc.install Dir["docs/*"]
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <cminpack.h>

      int main() {
          int m = 2;
          int n = 2;
          double x[2] = {-1.2, 1.0};
          double fvec[2] = {0};
          double fjac[4] = {0};
          double tol = 1e-8;
          int info = -1;
          int ipvt[2] = {0};
          int ldfjac = 2;
          int lwa = m * n + 5 * n + m;
          double wa[lwa];

          for (int i = 0; i < lwa; i++) {
              wa[i] = 0;
          }

          info = lmder1(NULL, NULL, 0, n, x, fvec, fjac, ldfjac, tol, ipvt, wa, lwa);

          if (info >= 0) {
              printf("Success: lmder1 returned %d\\n", info);
          } else {
              printf("Error: lmder1 returned %d\\n", info);
          }

          return info;
      }
    C

    system ENV.cc, "test.c", "-I#{include}/cminpack-1",
                   "-L#{lib}", "-lcminpack", "-lm", "-o", "test"
    system "./test"
  end
end
