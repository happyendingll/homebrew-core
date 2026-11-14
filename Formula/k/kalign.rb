class Kalign < Formula
  desc "Fast multiple sequence alignment program for biological sequences"
  homepage "https://github.com/TimoLassmann/kalign"
  url "https://github.com/TimoLassmann/kalign/archive/refs/tags/v4.0.0.tar.gz"
  sha256 "3292ac61a6d2af195e5100650b26cf87dcab75d14167ce39d5b4d5b78ebe5b77"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "76be3b66c1acae0e7429481bead16d15879e4cdd5fc627d4fd6356ce2491f7d1"
  end

  depends_on "cmake" => :build

  on_macos do
    depends_on "libomp"
  end

  deny_network_access!

  def install
    args = %w[
      -DENABLE_AVX=OFF
      -DENABLE_AVX2=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    input = ">1\nA\n>2\nA"
    (testpath/"test.fa").write(input)
    output = shell_output("#{bin}/kalign test.fa")
    assert_match input, output
  end
end
