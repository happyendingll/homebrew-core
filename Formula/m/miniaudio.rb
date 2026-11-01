class Miniaudio < Formula
  desc "Audio playback and capture library"
  homepage "https://miniaud.io"
  url "https://github.com/mackron/miniaudio/archive/refs/tags/0.11.26.tar.gz"
  sha256 "838ba55a21c9142adf7b76bdc4351e5cd8b7ae128f46b25ec25f94ae9969c600"
  license any_of: [:public_domain, "MIT-0"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "2fd82b1bc8e420e97b01efd02b20a0567129818d02b29ef3619a63d7bd2087c0"
  end

  depends_on "cmake" => :build

  def install
    args = %w[
      -DMINIAUDIO_BUILD_EXAMPLES=OFF
      -DMINIAUDIO_BUILD_TESTS=OFF
      -DMINIAUDIO_INSTALL=ON
      -DBUILD_SHARED_LIBS=ON
      -DMINIAUDIO_NO_EXTRA_NODES=ON
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <miniaudio/miniaudio.h>
      int main(void) {
        ma_context context;
        if (ma_context_init(NULL, 0, NULL, &context) != MA_SUCCESS) return 1;
        ma_context_uninit(&context);
        return 0;
      }
    C

    system ENV.cc, "test.c", "-o", "test", "-I#{include}", "-L#{lib}", "-lminiaudio", "-lm"
    system "./test"
  end
end
