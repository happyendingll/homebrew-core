class Flow < Formula
  desc "Static type checker for JavaScript"
  homepage "https://flow.org/"
  url "https://github.com/facebook/flow/archive/refs/tags/v0.337.0.tar.gz"
  sha256 "d7e0783e1cfbc5b04a04ccdc5e01624fe428e0062c715ce05dfc4116475d020c"
  license "MIT"
  head "https://github.com/facebook/flow.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "b31bddf75c2be73cede19c27eee3323c4d9bdcfd90af160167e7c4fef9865112"
  end

  depends_on "rust" => :build

  conflicts_with "flow-cli", "flow-control", because: "both install `flow` binaries"

  def install
    ENV["RUSTC_BOOTSTRAP"] = "1"
    system "cargo", "install", *std_cargo_args(path: "rust_port/crates/flow_cli")

    # Resulting binary name is `flow_cli` but in the release artifacts it is renamed to `flow`
    # https://github.com/facebook/flow/blob/main/.github/workflows/build_and_test.yml
    mv bin/"flow_cli", bin/"flow"

    bash_completion.install "resources/shell/bash-completion" => "flow-completion.bash"
    zsh_completion.install_symlink bash_completion/"flow-completion.bash" => "_flow"
  end

  test do
    system bin/"flow", "init", testpath
    (testpath/"test.js").write <<~JS
      /* @flow */
      var x: string = 123;
    JS
    expected = /Found 1 error/
    assert_match expected, shell_output("#{bin}/flow check #{testpath}", 2)
  end
end
