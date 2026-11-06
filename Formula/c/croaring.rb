class Croaring < Formula
  desc "Roaring bitmaps in C (and C++)"
  homepage "https://roaringbitmap.org"
  url "https://github.com/RoaringBitmap/CRoaring/archive/refs/tags/v5.5.5.tar.gz"
  sha256 "f78a93b8cf373fe4a3d31075cf2b3dc21dcfd7bbbc17674df35071ec8e461aef"
  license "Apache-2.0"
  compatibility_version 3
  head "https://github.com/RoaringBitmap/CRoaring.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "8f6f75e59ffd59d75e1bf9760e327fb1d34ebdee3025c8a604aff4f4603d7bf4"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_SHARED_LIBS=ON",
                    "-DENABLE_ROARING_TESTS=OFF",
                    "-DROARING_BUILD_LTO=ON",
                    "-DROARING_BUILD_STATIC=OFF",
                    "-DROARING_USE_CPM=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <roaring/roaring.h>
      int main() {
          roaring_bitmap_t *r1 = roaring_bitmap_create();
          for (uint32_t i = 100; i < 1000; i++) roaring_bitmap_add(r1, i);
          printf("cardinality = %d\\n", (int) roaring_bitmap_get_cardinality(r1));
          roaring_bitmap_free(r1);
          return 0;
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lroaring", "-o", "test"
    assert_equal "cardinality = 900\n", shell_output("./test")
  end
end
