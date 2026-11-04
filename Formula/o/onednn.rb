class Onednn < Formula
  desc "Basic building blocks for deep learning applications"
  homepage "https://www.oneapi.io/open-source/"
  url "https://github.com/uxlfoundation/oneDNN/archive/refs/tags/v3.14.2.tar.gz"
  sha256 "ed509c84b9d73bacabff00e6aaedbde570568e26dedb129030fee9c8c196f168"
  license "Apache-2.0"
  head "https://github.com/uxlfoundation/oneDNN.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "616a0e4dbe1ec78413a2d66af1834dcf9b698bc384f54b549b4017186fcceb29"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    # Keep KleidiAI's per-target `-march=...+fp16/+sve/+sme` flags; kernels are selected at runtime
    ENV.runtime_cpu_detection if Hardware::CPU.arm?

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <oneapi/dnnl/dnnl.h>
      int main() {
        dnnl_engine_t engine;
        dnnl_status_t status = dnnl_engine_create(&engine, dnnl_cpu, 0);
        return !(status == dnnl_success);
      }
    C

    system ENV.cc, "test.c", "-L#{lib}", "-ldnnl", "-o", "test"
    system "./test"
  end
end
