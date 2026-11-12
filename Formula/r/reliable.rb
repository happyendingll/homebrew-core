class Reliable < Formula
  desc "Simple packet acknowledgement system for UDP-based protocols"
  homepage "https://github.com/mas-bandwidth/reliable"
  url "https://github.com/mas-bandwidth/reliable/archive/refs/tags/v1.4.6.tar.gz"
  sha256 "7c4a0750d64748f69cb1b05ebaf44e3037914b91bab622ac36ac90d0c2c271f5"
  license "BSD-3-Clause"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "0c79fa3e7a8ac4f959f77750e479c0bb2991bf30f1b1bb5842ac147564b3ffdb"
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
      #include <reliable.h>
      #include <stdio.h>

      int main() {
        if (reliable_init() != RELIABLE_OK) {
          return 1;
        }
        printf("%s", RELIABLE_VERSION_FULL);
        reliable_term();
        return 0;
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lreliable", "-o", "test"
    assert_equal version.to_s, shell_output("./test")
  end
end
