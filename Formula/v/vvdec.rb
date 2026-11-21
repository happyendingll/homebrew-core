class Vvdec < Formula
  desc "Fraunhofer Versatile Video Decoder"
  homepage "https://www.hhi.fraunhofer.de/en/departments/vca/technologies-and-solutions/h266-vvc.html"
  url "https://github.com/fraunhoferhhi/vvdec/archive/refs/tags/v3.3.0.tar.gz"
  sha256 "8b09dbd3e3ea76972a6a2fb59e96b81a9c953f414e69f8a1b5a23eeca5bc2600"
  license "BSD-3-Clause-Clear"
  head "https://github.com/fraunhoferhhi/vvdec.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "b16df493961c2f6b4eac1e1d46fb8c48fdfbe92f8185d6c068cb277f0e1a3673"
  end

  depends_on "cmake" => :build

  resource "homebrew-test-video", :test do
    url "https://archive.org/download/testvideo_20230410_202304/test.vvc"
    sha256 "753261009b6472758cde0dee2c004ff712823b43e62ec3734f0f46380bec8e46"
  end

  allow_network_access! :test

  def install
    # SIMD implementations behind the per-source `-march` flags are chosen at runtime.
    ENV.runtime_cpu_detection

    system "cmake", "-S", ".", "-B", "build",
           "-DBUILD_SHARED_LIBS=1",
           "-DVVDEC_INSTALL_VVDECAPP=1",
           *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    resource("homebrew-test-video").stage testpath
    system bin/"vvdecapp", "-b", testpath/"test.vvc", "-o", testpath/"test.yuv"
    assert_path_exists testpath/"test.yuv"
  end
end
