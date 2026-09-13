class AwsChecksums < Formula
  desc "Cross-Platform HW accelerated CRC32c and CRC32 with fallback"
  homepage "https://github.com/awslabs/aws-checksums"
  url "https://github.com/awslabs/aws-checksums/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "6c058812f5b537ce58eac1e529f441ff387a652ea62cbe9b844f9188339221b1"
  license "Apache-2.0"
  compatibility_version 2

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "912096c8e8c5884c2a92d2c4273e7924c8dce1ee550c3647b5020d4c74b3f31c"
  end

  depends_on "cmake" => :build
  depends_on "aws-c-common"

  def install
    # Intel: https://github.com/awslabs/aws-checksums/commit/e03e976974d27491740c98f9132a38ee25fb27d0
    # ARM:   https://github.com/awslabs/aws-checksums/commit/d7005974347050a97b13285eb0108dd1e59cf2c4
    ENV.runtime_cpu_detection

    system "cmake", "-S", ".", "-B", "build", "-DBUILD_SHARED_LIBS=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <aws/checksums/crc.h>
      #include <aws/common/allocator.h>
      #include <assert.h>

      int main(void) {
        struct aws_allocator *allocator = aws_default_allocator();
        const size_t len = 3 * 1024 * 1024 * 1024ULL;
        const uint8_t *many_zeroes = aws_mem_calloc(allocator, len, sizeof(uint8_t));
        uint32_t result = aws_checksums_crc32_ex(many_zeroes, len, 0);
        aws_mem_release(allocator, (void *)many_zeroes);
        assert(0x480BBE37 == result);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-o", "test", "-L#{lib}", "-laws-checksums",
                   "-L#{formula_opt_lib("aws-c-common")}", "-laws-c-common"
    system "./test"
  end
end
