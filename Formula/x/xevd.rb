class Xevd < Formula
  desc "Very fast Essential Video Decoder, MPEG-5 EVC (Essential Video Coding)"
  homepage "https://github.com/mpeg5/xevd"
  url "https://github.com/mpeg5/xevd/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "febfdb532819bbf36b1b04e74d3ef328ad0f0f2db6224ddb7640fce6bd0014f4"
  license "BSD-3-Clause"
  head "https://github.com/mpeg5/xevd.git", branch: "master"

  # Regex is needed to avoid picking up non-semver tags
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "464aa6debe8520c3be6a7ae011563cc75452bdb9b11b8044e8bfbefe93778251"
  end

  depends_on "cmake" => :build
  depends_on "xeve" => :test

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DSET_PROF=MAIN", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # 10 frames of 64x64 YUV420p, encoded by the sibling encoder to avoid an external bitstream
    (testpath/"in.yuv").binwrite("\x80" * (64 * 64 * 3 / 2 * 10))
    system formula_opt_bin("xeve")/"xeve_app", "-i", "in.yuv", "-w", "64", "-h", "64",
                                               "--fps", "25", "-o", "in.evc"

    system bin/"xevd_app", "-i", "in.evc", "-o", "out.yuv"
    assert_equal (testpath/"in.yuv").size, (testpath/"out.yuv").size
  end
end
