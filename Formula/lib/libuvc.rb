class Libuvc < Formula
  desc "Cross-platform library for USB video devices"
  homepage "https://libuvc.github.io/"
  url "https://github.com/libuvc/libuvc/archive/refs/tags/v0.0.9.tar.gz"
  sha256 "825775b21b8558ac2afcbc2561ab1e5081898c9b0296673fcaa7cabb6e94078e"
  license "BSD-3-Clause"
  head "https://github.com/libuvc/libuvc.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "96b7403977d1a107ed200dd3f3d94191a0a88a949071514881a828c34a05900d"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "libusb"

  deny_network_access!

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
