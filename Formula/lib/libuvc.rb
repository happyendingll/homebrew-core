class Libuvc < Formula
  desc "Cross-platform library for USB video devices"
  homepage "https://libuvc.github.io/"
  url "https://github.com/libuvc/libuvc/archive/refs/tags/v0.0.8.tar.gz"
  sha256 "abe134716f4c53fe60db2004b42adf6af60e64e45808135acfa4311454371ece"
  license "BSD-3-Clause"
  head "https://github.com/libuvc/libuvc.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "3cd360d25c06d9bc339e0b19e382f6760e7b1ece869f10515eb40820c4840508"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "libusb"

  def install
    # Workaround to build with CMake 4
    args = %w[-DCMAKE_POLICY_VERSION_MINIMUM=3.5]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <libuvc/libuvc.h>
      int main() {
        uvc_context_t *ctx;
        uvc_error_t res = uvc_init(&ctx, NULL);
        if (res != UVC_SUCCESS) return 1;
        uvc_exit(ctx);
        return 0;
      }
    C

    flags = shell_output("pkgconf --cflags --libs libuvc").strip.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
