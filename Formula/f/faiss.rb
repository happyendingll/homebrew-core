class Faiss < Formula
  desc "Efficient similarity search and clustering of dense vectors"
  homepage "https://faiss.ai"
  url "https://github.com/facebookresearch/faiss/archive/refs/tags/v1.16.0.tar.gz"
  sha256 "4bef4f97e7e0a88c150f6c85897bdda411dd875522e7bf601ad27dfe6f55179d"
  license "MIT"
  compatibility_version 1

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "8c092221f094cdcf93840c1bdc026c2c5bda7acc5dc35822a844c5ffb64ec133"
  end

  depends_on "cmake" => :build
  depends_on "openblas"

  on_macos do
    depends_on "libomp"
  end

  def install
    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DFAISS_ENABLE_C_API=ON
      -DFAISS_ENABLE_GPU=OFF
      -DFAISS_ENABLE_PYTHON=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    pkgshare.install "demos"
  end

  test do
    cp pkgshare/"demos/demo_imi_flat.cpp", testpath
    system ENV.cxx, "-std=c++17", "demo_imi_flat.cpp", "-L#{lib}", "-lfaiss", "-o", "test"
    assert_match "Query results", shell_output("./test")
  end
end
