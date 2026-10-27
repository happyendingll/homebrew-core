class Cppinsights < Formula
  desc "See your source code with the eyes of a compiler"
  homepage "https://cppinsights.io/"
  url "https://github.com/andreasfertig/cppinsights/archive/refs/tags/v_23.1.tar.gz"
  sha256 "2c2ac2f96612e8e789c96305031dd55af3d399a572989827d1657c388cdbdbb6"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "21703b5c5e91e4445b930fabd85dedf0242d88111fb86c455542c6b29a21a7e9"
  end

  depends_on "cmake" => :build
  depends_on "llvm"

  fails_with :clang do
    build 1500
    cause "Requires Clang > 15.0"
  end

  fails_with :gcc do
    version "14"
    cause "GNU version must be at least 15.1"
  end

  deny_network_access!

  def install
    args = %W[
      -DINSIGHTS_LLVM_CONFIG=#{formula_opt_bin("llvm")}/llvm-config
      -DINSIGHTS_USE_SYSTEM_INCLUDES=OFF
      -DCLANG_LINK_CLANG_DYLIB=ON
      -DLLVM_LINK_LLVM_DYLIB=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      int main() {
        int arr[5]{2,3,4};
      }
    CPP
    assert_match "{2, 3, 4, 0, 0}", shell_output("#{bin}/insights ./test.cpp")
  end
end
