class AwsCCommon < Formula
  desc "Core c99 package for AWS SDK for C"
  homepage "https://github.com/awslabs/aws-c-common"
  url "https://github.com/awslabs/aws-c-common/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "74d001d5900868e8145b6968832d6273215df5342b8df69afcc3d6dfd59f430b"
  license "Apache-2.0"
  compatibility_version 2

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "89dbfad5e18228a90a3a255bc494617cf99dd314570f8137f74d336230003768"
    sha256 cellar: :any, arm64_tahoe:       "452db7c681ba9a84b31e272fec6fc8cec95c761a56490f6d1ac3b05a6874a5e2"
    sha256 cellar: :any, arm64_sequoia:     "192e60c37f337719148d90c3be611a208d7d0e71b46786e249bbc45f23b9a7eb"
    sha256 cellar: :any, arm64_linux:       "3929a6e6714b72a9e8d90c5021e1cadf8622a8be483597450c2543e0b9297090"
    sha256 cellar: :any, x86_64_linux:      "59cf4ebff1ab4b3d0a590ec0b357e4033fe0afe8df3396361bbc70b7330e13d0"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", "-DBUILD_SHARED_LIBS=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <aws/common/uuid.h>
      #include <aws/common/byte_buf.h>
      #include <aws/common/error.h>
      #include <assert.h>

      int main(void) {
        struct aws_uuid uuid;
        assert(AWS_OP_SUCCESS == aws_uuid_init(&uuid));

        uint8_t uuid_array[AWS_UUID_STR_LEN] = {0};
        struct aws_byte_buf uuid_buf = aws_byte_buf_from_array(uuid_array, sizeof(uuid_array));
        uuid_buf.len = 0;

        assert(AWS_OP_SUCCESS == aws_uuid_to_str(&uuid, &uuid_buf));
        uint8_t zerod_buf[AWS_UUID_STR_LEN] = {0};
        assert(AWS_UUID_STR_LEN - 1 == uuid_buf.len);
        assert(0 != memcmp(zerod_buf, uuid_array, sizeof(uuid_array)));

        return 0;
      }
    C
    system ENV.cc, "test.c", "-o", "test", "-L#{lib}", "-laws-c-common"
    system "./test"
  end
end
