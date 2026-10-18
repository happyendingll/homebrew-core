class Lapack < Formula
  desc "Linear Algebra PACKage"
  homepage "https://www.netlib.org/lapack/"
  url "https://github.com/Reference-LAPACK/lapack/archive/refs/tags/v3.12.1.tar.gz"
  sha256 "2ca6407a001a474d4d4d35f3a61550156050c48016d949f0da0529c0aa052422"
  # LAPACK is BSD-3-Clause-Open-MPI while LAPACKE is BSD-3-Clause
  license all_of: ["BSD-3-Clause-Open-MPI", "BSD-3-Clause"]
  revision 1
  head "https://github.com/Reference-LAPACK/lapack.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "31595056f1ae16c6bc3b2be92c72a39f316638d3c7a2c4f902a2af4add38ad4b"
  end

  keg_only :shadowed_by_macos, "macOS provides LAPACK in Accelerate.framework"

  depends_on "cmake" => :build
  depends_on "gcc" # for gfortran

  on_linux do
    keg_only "it conflicts with openblas"
  end

  deny_network_access!

  def install
    ENV.delete("MACOSX_DEPLOYMENT_TARGET")

    # CMake FortranCInterface_VERIFY fails with LTO on Linux due to different GCC and GFortran versions
    ENV.append "FFLAGS", "-fno-lto" if OS.linux?

    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DCBLAS=ON
      -DLAPACKE=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"lp.c").write <<~C
      #include "lapacke.h"
      #include <complex.h>
      #include <math.h>
      #include <string.h>

      typedef double _Complex cplx;

      static unsigned long lcg_state;

      static void lcg_seed(unsigned long seed) {
        lcg_state = seed;
      }

      static double lcg_unit(void) {
        lcg_state = lcg_state * 6364136223846793005UL + 1442695040888963407UL;
        return (double)((lcg_state >> 11) & 0x1FFFFFFFFFFFFFUL) / (double)0x20000000000000UL;
      }

      int main() {
        void *p = LAPACKE_malloc(sizeof(char)*100);
        if (p) {
          LAPACKE_free(p);
        }

        const int n = 3;
        lapack_complex_double a[n * n], a_orig[n * n], w[n], vr[n * n];
        double max_residual = 0.0;
        lapack_int info;

        lcg_seed(20260820UL + n);
        for (int i = 0; i < n * n; i++) {
          a_orig[i] = (2.0 * lcg_unit() - 1.0) + (2.0 * lcg_unit() - 1.0) * I;
        }

        memcpy(a, a_orig, sizeof(a));
        info = LAPACKE_zgeev(LAPACK_COL_MAJOR, 'N', 'V', n, a, n, w, NULL, 1, vr, n);
        if (info != 0) {
          return 1;
        }

        for (int j = 0; j < n; j++) {
          for (int i = 0; i < n; i++) {
            cplx av = 0.0;
            for (int k = 0; k < n; k++) {
              av += a_orig[k * n + i] * vr[j * n + k];
            }

            double residual = cabs(av - w[j] * vr[j * n + i]);
            if (residual > max_residual) {
              max_residual = residual;
            }
          }
        }

        if (max_residual > 1e-10) {
          return 1;
        }

        return 0;
      }
    C
    system ENV.cc, "lp.c", "-I#{include}", "-L#{lib}", "-llapacke", "-llapack", "-lblas", "-lm", "-o", "lp"
    system "./lp"
  end
end
