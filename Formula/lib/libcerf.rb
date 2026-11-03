class Libcerf < Formula
  desc "Numeric library for complex error functions"
  homepage "https://jugit.fz-juelich.de/mlz/lib/cerf"
  url "https://jugit.fz-juelich.de/mlz/lib/cerf/-/archive/v3.9/cerf-v3.9.tar.bz2"
  sha256 "a227f03379c8d811ef80c7e9b4c8fdac6bed696602cb38dff026c29cb012dbf7"
  license "MIT"
  version_scheme 1
  compatibility_version 1
  head "https://jugit.fz-juelich.de/mlz/lib/cerf.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "849fa8e90a7c7c6ca9964f525a7434b1052f439ed08ac319f8a8385cfdd1427b"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <cerf.h>
      #include <complex.h>
      #include <math.h>
      #include <stdio.h>
      #include <stdlib.h>

      int main (void) {
        double _Complex a = 1.0 - 0.4I;
        a = cerf(a);
        if (fabs(creal(a)-0.910867) > 1.e-6) abort();
        if (fabs(cimag(a)+0.156454) > 1.e-6) abort();
        return 0;
      }
    C

    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lcerf", "-o", "test"
    system "./test"
  end
end
