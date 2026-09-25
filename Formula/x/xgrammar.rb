class Xgrammar < Formula
  desc "Structured generation and reasoning engine for LLMs"
  homepage "https://xgrammar.mlc.ai/"
  url "https://github.com/mlc-ai/xgrammar/archive/refs/tags/v0.2.8.tar.gz"
  sha256 "16c06f7cef8f13ae597b007cce515991725603bded6ebce5f1828e6a9c9685be"
  license "Apache-2.0"
  head "https://github.com/mlc-ai/xgrammar.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "57c9d8f2fdaf81d46ecd1941aaf0a1b6cbf107ec91a04b537e39f5f73b997021"
  end

  depends_on "cmake" => :build
  depends_on "dlpack"

  deny_network_access!

  def install
    # `cmake/config.cmake` shadows the cache options with normal variables, so ship our own
    (buildpath/"build").mkpath
    (buildpath/"build/config.cmake").write "set(XGRAMMAR_BUILD_PYTHON_BINDINGS OFF)\n"

    # Stand in for the dlpack submodule, which the tarball does not ship
    (buildpath/"3rdparty/dlpack/include").install_symlink formula_opt_include("dlpack")/"dlpack"

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # The headers are installed by the `dlpack` formula itself
    rm include/"dlpack"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <xgrammar/compiler.h>
      #include <xgrammar/matcher.h>
      #include <xgrammar/tokenizer_info.h>

      #include <cassert>
      #include <string>
      #include <vector>

      int main() {
        std::vector<std::string> vocab = {"{", "}", ":", ",", "0", "1"};
        xgrammar::TokenizerInfo tokenizer(vocab);
        xgrammar::GrammarCompiler compiler(tokenizer, 1, false, -1);
        auto grammar = compiler.CompileBuiltinJSONGrammar();
        assert(grammar.MemorySizeBytes() > 0);
      }
    CPP
    system ENV.cxx, "test.cpp", "-std=c++17", "-I#{include}", "-L#{lib}", "-lxgrammar", "-o", "test"
    system "./test"
  end
end
