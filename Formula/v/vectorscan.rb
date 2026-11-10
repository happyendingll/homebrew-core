class Vectorscan < Formula
  desc "High-performance regular expression matching library"
  homepage "https://github.com/VectorCamp/vectorscan"
  url "https://github.com/VectorCamp/vectorscan/archive/refs/tags/vectorscan/5.4.14.tar.gz"
  sha256 "8a035e5a7e769f3793d50645a17042bcd601a2f9835b32c535eae7b1a9b9f0e0"
  license "BSD-3-Clause"
  compatibility_version 1
  head "https://github.com/VectorCamp/vectorscan.git", branch: "develop"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "cec74fe9e5b0525ccc09b39457d45cf9e9ab5f91510a5fe5a38b17c8650471b9"
  end

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "ragel" => :build

  deny_network_access!

  def install
    # Avoid building hscollider which needs EOL `pcre`
    # Issue ref: https://github.com/VectorCamp/vectorscan/issues/320
    rm("tools/hscollider/CMakeLists.txt")

    cmake_args = [
      "-DCCACHE_FOUND=CCACHE_FOUND-NOTFOUND",
      "-DBUILD_STATIC_LIBS=ON",
      "-DBUILD_SHARED_LIBS=ON",
      "-DFAT_RUNTIME=OFF",
    ]

    system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <hs/hs.h>
      int main()
      {
        printf("hyperscan v%s", hs_version());
        return 0;
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lhs", "-o", "test"
    assert_match version.to_s, shell_output("./test")
  end
end
