class Convco < Formula
  desc "Conventional commits, changelog, versioning, validation"
  homepage "https://convco.github.io"
  url "https://github.com/convco/convco/archive/refs/tags/v0.7.2.tar.gz"
  sha256 "b73c702e93e9e29f9b57faf497e812a94edb773e2f7d67d7b0481b03464f1b24"
  license "MIT"
  head "https://github.com/convco/convco.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "1fe8a3e60c263361fc5ad0670afd96e8987dfe4c4d87f324d8e6cc62018f9bf9"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--no-default-features", *std_cargo_args(features: "gix")

    bash_completion.install "target/completions/convco.bash" => "convco"
    zsh_completion.install  "target/completions/_convco" => "_convco"
    fish_completion.install "target/completions/convco.fish" => "convco.fish"
  end

  test do
    system "git", "init"
    system "git", "commit", "--allow-empty", "-m", "invalid"
    assert_match(/FAIL  \w+  first line doesn't match `<type>\[optional scope\]: <description>`  invalid\n/,
      shell_output("#{bin}/convco check", 1).lines.first)
  end
end
