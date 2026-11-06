class Streamvbyte < Formula
  desc "Fast integer compression in C"
  homepage "https://fast-pack.github.io/streamvbyte/"
  url "https://github.com/fast-pack/streamvbyte/archive/refs/tags/v3.0.2.tar.gz"
  sha256 "81e90202bc80145d54ca1a2402fb8143fc640c4e5f90cde135d71d02860f5635"
  license "Apache-2.0"
  head "https://github.com/fast-pack/streamvbyte.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "72e1bf9241c4df2425daa5998bc064d0ba8ce18ed06ab0b5d77ad27b54326cb1"
  end

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", "-DCMAKE_POLICY_VERSION_MINIMUM=3.5", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "examples/example.c"
  end

  test do
    system ENV.cc, pkgshare/"example.c", "-I#{include}", "-L#{lib}", "-lstreamvbyte", "-o", "test"
    system testpath/"test"
  end
end
