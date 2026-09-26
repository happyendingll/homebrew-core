class Nanoarrow < Formula
  desc "Helpers for Arrow C Data & Arrow C Stream interfaces"
  homepage "https://arrow.apache.org/nanoarrow"
  url "https://github.com/apache/arrow-nanoarrow/releases/download/apache-arrow-nanoarrow-0.9.0/apache-arrow-nanoarrow-0.9.0.tar.gz"
  sha256 "801200a0e95e869d5c4bdeb5b535dba58551482bb782b7dc8bd599c8b6e8cacf"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "fce310bca6d90c48d7a19372ccfd96a00d0a86fc1d2467de0f3dd534aea3a04c"
  end

  depends_on "cmake" => :build
  depends_on "flatcc"

  # Allow linking against a shared flatccrt
  patch do
    url "https://github.com/apache/arrow-nanoarrow/commit/4c8bedd1db791914068cb19e17a98c5e6ef70582.patch?full_index=1"
    sha256 "e77804be9bd97b638e4aa22f490c2bcb1646d8b6d5fa11b4e1a33ab82aca598f"
    type :unofficial
    resolves "https://github.com/apache/arrow-nanoarrow/pull/949"
  end

  deny_network_access!

  def install
    args = %W[
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DNANOARROW_FLATCC_ROOT_DIR=#{formula_opt_prefix("flatcc")}
      -DNANOARROW_IPC=ON
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <nanoarrow/nanoarrow.h>

      int main() {
        ArrowBufferAllocatorDefault();
        return 0;
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-lnanoarrow_shared", "-o", "test"
    system "./test"

    # Test IPC functionality
    (testpath/"test_ipc.c").write <<~C
      #include <nanoarrow/nanoarrow.h>
      #include <nanoarrow/nanoarrow_ipc.h>

      int main() {
        struct ArrowIpcInputStream input;
        input.release = NULL;
        return 0;
      }
    C
    system ENV.cc, "test_ipc.c", "-L#{lib}", "-lnanoarrow_shared", "-lnanoarrow_ipc_shared", "-o", "test_ipc"
    system "./test_ipc"
  end
end
