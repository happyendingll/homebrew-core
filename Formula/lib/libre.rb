class Libre < Formula
  desc "Toolkit library for asynchronous network I/O with protocol stacks"
  homepage "https://github.com/baresip/re"
  url "https://github.com/baresip/re/archive/refs/tags/v4.13.0.tar.gz"
  sha256 "3e62b66cb833f22561ec3351647efb3c488766978d72f56de1039a7e5ddf70a9"
  license "BSD-3-Clause"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "7364264459eb6910e3165f35903ac56656e433f7a42f3102aada41384ea7665c"
  end

  depends_on "cmake" => :build
  depends_on "openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdint.h>
      #include <re/re.h>
      int main() {
        return libre_init();
      }
    C
    system ENV.cc, "test.c", "-o", "test", "-I#{include}", "-I#{include}/re", "-L#{lib}", "-lre"
    system "./test"
  end
end
