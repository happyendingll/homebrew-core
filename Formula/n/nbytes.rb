class Nbytes < Formula
  desc "Library of byte handling functions extracted from Node.js core"
  homepage "https://github.com/nodejs/nbytes"
  url "https://github.com/nodejs/nbytes/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "5158c92a34b02f54778ae7367dab77cc02861c69f4d8cfd4eeed608d586ca900"
  license "MIT"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "df07d1af2588810020f4684c128e56a45f397b2f5d37d6b9cffc225f3f4d30ac"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test-main.cpp").write <<~CPP
      #include <nbytes.h>
      #include <iostream>

      int main() {
        constexpr char input[] = "SGVsbG8sIFdvcmxkIQ=="; // "Hello, World!"
        char output[64] = {};
        size_t n = nbytes::Base64Decode(output, sizeof(output), input, sizeof(input) - 1);
        std::cout << output << std::endl;
        return 0;
      }
    CPP

    system ENV.cxx, "-std=c++20", "test-main.cpp", "-I#{include}", "-L#{lib}", "-lnbytes", "-o", "test-main"

    assert_equal "Hello, World!\n", shell_output("./test-main")
  end
end
