class Wasmedge < Formula
  desc "Lightweight, high-performance, and extensible WebAssembly runtime"
  homepage "https://WasmEdge.org/"
  url "https://github.com/WasmEdge/WasmEdge/releases/download/0.17.2/WasmEdge-0.17.2-src.tar.gz"
  sha256 "7f2ef28b45bc136ee1f13a3453caab91d0dd2ba141dce599008486b561a63eac"
  license "Apache-2.0"
  head "https://github.com/WasmEdge/WasmEdge.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "e93c84f865d7ef8b318e1c16c9d66f4a2db001ed83c6eb5bdfe67144be0c7ba1"
  end

  depends_on "cmake" => :build
  depends_on "fmt"
  depends_on "lld"
  depends_on "llvm"
  depends_on "spdlog"

  # fmt 12.2 dropped operator~ on uint128_fallback; upstream fix not in 0.17.1.
  patch do
    url "https://github.com/WasmEdge/WasmEdge/commit/41a01b6b4f40defbac0dd551663c542cdcf9ae76.patch?full_index=1"
    sha256 "55657c3a628a406b655ba224019f0121f2489140dca128c3f8c623c019de84b1"
    type :backport
    resolves "https://github.com/WasmEdge/WasmEdge/pull/4936"
  end

  deny_network_access!

  def install
    # Use CMAKE_BUILD_WITH_INSTALL_RPATH to keep versioned LLVM in RPATH on Linux
    args = ["-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON"] if OS.linux?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # sum.wasm was taken from wasmer.rb
    wasm = ["0061736d0100000001070160027f7f017f030201000707010373756d00000a09010700200020016a0b"].pack("H*")
    (testpath/"sum.wasm").write(wasm)
    assert_equal "3\n",
      shell_output("#{bin}/wasmedge --reactor #{testpath/"sum.wasm"} sum 1 2")
  end
end
