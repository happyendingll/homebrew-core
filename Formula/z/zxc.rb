class Zxc < Formula
  desc "High-performance asymmetric lossless compression library"
  homepage "https://github.com/hellobertrand/zxc"
  url "https://github.com/hellobertrand/zxc/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "b589d2cabc4e577cb09a4faf18a7d787d93379db6918c7ae6e3cae4a07ba86bc"
  license "BSD-3-Clause"
  head "https://github.com/hellobertrand/zxc.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "385d179e954290674308af187dc02d0a58512e34b2ef91da5fb0f93df30b3a77"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DZXC_NATIVE_ARCH=OFF
      -DZXC_BUILD_TESTS=OFF
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    input = "Hello world"
    compressed = pipe_output(bin/"zxc", input)
    refute_empty compressed
    decompressed = pipe_output("#{bin}/zxc -d", compressed)
    assert_equal input, decompressed
  end
end
