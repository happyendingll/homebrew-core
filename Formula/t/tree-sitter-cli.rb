class TreeSitterCli < Formula
  desc "Parser generator tool"
  homepage "https://tree-sitter.github.io"
  url "https://github.com/tree-sitter/tree-sitter/archive/refs/tags/v0.27.0.tar.gz"
  sha256 "d35c96e68736bd9569d2757c3cc71052485f33082c3825f1aed9d0e86013a159"
  license "MIT"
  head "https://github.com/tree-sitter/tree-sitter.git", branch: "master"

  livecheck do
    formula "tree-sitter"
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "41525f19ed1d9566c6c420157db14e6f090b205e249e28a4f80d012c05d83d27"
  end

  depends_on "rust" => :build
  depends_on "node" => :test

  uses_from_macos "llvm" => :build

  link_overwrite "bin/tree-sitter"
  link_overwrite "etc/bash_completion.d/tree-sitter"
  link_overwrite "share/fish/vendor_completions.d/tree-sitter.fish", "share/zsh/site-functions/_tree-sitter"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/cli")
    generate_completions_from_executable(bin/"tree-sitter", "complete", shell_parameter_format: :arg)
  end

  test do
    # a trivial tree-sitter test
    assert_equal "tree-sitter #{version}", shell_output("#{bin}/tree-sitter --version").strip

    # test `tree-sitter generate`
    (testpath/"grammar.js").write <<~JS
      module.exports = grammar({
        name: 'YOUR_LANGUAGE_NAME',
        rules: {
          source_file: $ => 'hello'
        }
      });
    JS
    system bin/"tree-sitter", "generate", "--abi=latest"

    # test `tree-sitter parse`
    (testpath/"test/corpus/hello.txt").write <<~EOS
      hello
    EOS
    parse_result = shell_output("#{bin}/tree-sitter parse #{testpath}/test/corpus/hello.txt").strip
    assert_equal("(source_file [0, 0] - [1, 0])", parse_result)

    # test `tree-sitter test`
    (testpath/"test/corpus/test_case.txt").write <<~EOS
      =========
        hello
      =========
      hello
      ---
      (source_file)
    EOS
    system bin/"tree-sitter", "test"
  end
end
