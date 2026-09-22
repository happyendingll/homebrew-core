class CBlosc2 < Formula
  desc "Fast, compressed, persistent binary data store library for C"
  homepage "https://www.blosc.org"
  url "https://github.com/Blosc/c-blosc2/archive/refs/tags/v3.3.4.tar.gz"
  sha256 "db6ba3ee4f863a3c15794fbba99a4e5704d6a01017799628546152c8f4b06818"
  license "BSD-3-Clause"
  compatibility_version 1
  head "https://github.com/Blosc/c-blosc2.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "ef44356825b1a9f79d4da11d680e92aaeb1d5cbe5d04086584bb4b34548b3e12"
  end

  depends_on "cmake" => :build
  depends_on "lz4"
  depends_on "zstd"

  on_macos do
    depends_on "llvm" => :build if DevelopmentTools.clang_build_version <= 1400
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  fails_with :clang do
    build 1400
  end

  deny_network_access!

  def install
    args = %w[
      -DBUILD_TESTS=OFF
      -DBUILD_FUZZERS=OFF
      -DBUILD_BENCHMARKS=OFF
      -DBUILD_EXAMPLES=OFF
      -DBUILD_PLUGINS=OFF
      -DPREFER_EXTERNAL_LZ4=ON
      -DPREFER_EXTERNAL_ZLIB=ON
      -DPREFER_EXTERNAL_ZSTD=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "examples/simple.c"
  end

  test do
    system ENV.cc, pkgshare/"simple.c", "-I#{include}", "-L#{lib}", "-lblosc2", "-o", "test"
    assert_match "Successful roundtrip!", shell_output(testpath/"test")
  end
end
