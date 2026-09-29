class Enzyme < Formula
  desc "High-performance automatic differentiation of LLVM"
  homepage "https://enzyme.mit.edu"
  url "https://github.com/EnzymeAD/Enzyme/archive/refs/tags/v0.0.298.tar.gz"
  sha256 "8a8d331636a301c6e15b9c2ff2fffe28bf23f82cc57ee3fc412217cb3596439c"
  license "Apache-2.0" => { with: "LLVM-exception" }
  head "https://github.com/EnzymeAD/Enzyme.git", branch: "main"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "33692292c6dd28f681a1712f663b0755b2958e0a0f0f2781078bdad7128e4b0e"
    sha256 cellar: :any, arm64_tahoe:       "96aaac4bb262d44d1a17d52ac498c9506606b4520acff011b8f382deec17310e"
    sha256 cellar: :any, arm64_sequoia:     "064480d0156cc614cde2212876a09733aa10a42d83b60cfad6e8144ebc50f2fd"
    sha256 cellar: :any, arm64_linux:       "e36489f08106151088a87e2f9340c89620e83349b9da425432a631234593e8a9"
    sha256 cellar: :any, x86_64_linux:      "fb935e270688c36b3fd3f45c2d79510bfb18434664a55e9cfb92b45598f1fd3b"
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
