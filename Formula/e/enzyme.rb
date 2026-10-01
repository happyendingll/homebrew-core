class Enzyme < Formula
  desc "High-performance automatic differentiation of LLVM"
  homepage "https://enzyme.mit.edu"
  url "https://github.com/EnzymeAD/Enzyme/archive/refs/tags/v0.0.300.tar.gz"
  sha256 "545e0819b28b11a570d1e4051437e04057f411ec7f897f77df6a84f9b650c5d5"
  license "Apache-2.0" => { with: "LLVM-exception" }
  head "https://github.com/EnzymeAD/Enzyme.git", branch: "main"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "73e5cf6af5a63e06864974770c846272b54900fb22f7655b9c74ebd7c62007dd"
    sha256 cellar: :any, arm64_tahoe:       "003f55b1a87ef0fe8601f4d49f6355db1c69ee3e88abbdd82c7d98c7e74fbcf3"
    sha256 cellar: :any, arm64_sequoia:     "8aa417afbdf3cf868f866551e74ca43046eba398b2434ae13b8cedf7836ebc56"
    sha256 cellar: :any, arm64_linux:       "440416b2cb8d17d55b32ad9e18657107f18a1701b3815c04e7917c808fc25160"
    sha256 cellar: :any, x86_64_linux:      "5cad5b93b5846ceea74f3d5137287afee6ae30ca67ebe99b8329941146a3bf67"
  end

  depends_on "cmake" => :build
  depends_on "llvm"

  def llvm
    deps.map(&:to_formula).find { |f| f.name.match?(/^llvm(@\d+)?$/) }
  end

  deny_network_access!

  def install
    system "cmake", "-S", "enzyme", "-B", "build", "-DLLVM_DIR=#{llvm.opt_lib}/cmake/llvm", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      extern double __enzyme_autodiff(void*, double);
      double square(double x) {
        return x * x;
      }
      double dsquare(double x) {
        return __enzyme_autodiff(square, x);
      }
      int main() {
        double i = 21.0;
        printf("square(%.0f)=%.0f, dsquare(%.0f)=%.0f", i, square(i), i, dsquare(i));
      }
    C

    ENV["CC"] = llvm.opt_bin/"clang"

    plugin = lib/shared_library("ClangEnzyme-#{llvm.version.major}")
    system ENV.cc, "test.c", "-fplugin=#{plugin}", "-O1", "-o", "test"
    assert_equal "square(21)=441, dsquare(21)=42", shell_output("./test")
  end
end
