class Cnats < Formula
  desc "C client for the NATS messaging system"
  homepage "https://github.com/nats-io/nats.c"
  url "https://github.com/nats-io/nats.c/archive/refs/tags/v3.15.0.tar.gz"
  sha256 "aed133ecf121b0ec454c9d28d34edab41898f56a67dacce09a1a645e84c0edfe"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "322fc20a62595ddb6506b52093b5b38aaebe655de865ab4e02d6c7bfe224855a"
  end

  depends_on "cmake" => :build
  depends_on "libevent"
  depends_on "libuv"
  depends_on "openssl@4"
  depends_on "protobuf-c"

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <nats/nats.h>
      #include <stdio.h>
      int main() {
        printf("%s\\n", nats_GetVersion());
        return 0;
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-lnats", "-o", "test"
    assert_equal version, shell_output("./test").strip
  end
end
