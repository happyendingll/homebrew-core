class Mimalloc < Formula
  desc "Compact general purpose allocator"
  homepage "https://github.com/microsoft/mimalloc"
  url "https://github.com/microsoft/mimalloc/archive/refs/tags/v3.5.2.tar.gz"
  sha256 "db5c4aaaf356edfeb1aa236b3a052fe3c67d01419db36613f783999341ed5619"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "d076d7e0c522d9bd6edb971224ff35eba58aabb53e5c388a1db26a358dd7498b"
  end

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", "-DMI_INSTALL_TOPLEVEL=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    pkgshare.install "test"
  end

  test do
    cp pkgshare/"test/main.c", testpath
    system ENV.cc, "main.c", "-L#{lib}", "-lmimalloc", "-o", "test"
    assert_match(/pages\s+peak\s+total\s+current\s+block\s+total/, shell_output("./test 2>&1"))
  end
end
