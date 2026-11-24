class Embree < Formula
  desc "High-performance ray tracing kernels"
  homepage "https://www.embree.org/"
  url "https://github.com/RenderKit/embree/archive/refs/tags/v4.5.0.tar.gz"
  sha256 "6692fdf2b55831ac58732459443336d709974051d7ec642b3e1fcf06271b5eea"
  license "Apache-2.0"
  compatibility_version 1
  head "https://github.com/RenderKit/embree.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "eee2a75000ce826d9e3321c82deaafa45d8fbac3625bbcce9bd8fa90be7e2897"
  end

  depends_on "cmake" => :build
  depends_on "ispc" => :build
  depends_on "tbb"

  deny_network_access!

  def install
    # Enable maximum ISA as it is detected at runtime
    ENV.runtime_cpu_detection
    max_isa = Hardware::CPU.intel? ? "AVX512" : "NEON2X"
    args = %W[
      -DEMBREE_IGNORE_CMAKE_CXX_FLAGS=OFF
      -DEMBREE_ISPC_SUPPORT=ON
      -DEMBREE_TUTORIALS=OFF
      -DEMBREE_MAX_ISA=#{max_isa}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <assert.h>
      #include <embree4/rtcore.h>

      int main() {
        RTCDevice device = rtcNewDevice("verbose=1");
        assert(device != 0);
        rtcReleaseDevice(device);
        return 0;
      }
    C

    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lembree4"
    assert_match "Embree Ray Tracing Kernels #{version} ()", shell_output("./a.out")
  end
end
