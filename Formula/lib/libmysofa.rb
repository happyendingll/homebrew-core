class Libmysofa < Formula
  desc "Reader for AES SOFA files to get better HRTFs"
  homepage "https://github.com/hoene/libmysofa"
  url "https://github.com/hoene/libmysofa/archive/refs/tags/v1.3.5.tar.gz"
  sha256 "f29508c335c83d8703f943ffc9ca783ac39aca84e851357f13a55af0f8143137"
  license "BSD-3-Clause"
  head "https://github.com/hoene/libmysofa.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "a86c61e4f639a8fde11c8a004b6b10eb507f0714e04fb25260261181c4b09dd0"
  end

  depends_on "cmake" => :build
  depends_on "cunit" => :build

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <mysofa.h>

      int main(void)
      {
        int err;

        struct MYSOFA_HRTF *m = mysofa_load("#{share}/libmysofa/default.sofa", &err);
        if (!m) return 1;

        mysofa_free(m);
        return 0;
      }
    C

    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lmysofa", "-o", "test"
    system "./test"
  end
end
