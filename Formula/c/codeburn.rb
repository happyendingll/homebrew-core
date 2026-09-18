class Codeburn < Formula
  desc "See where your AI coding tokens go - by task, tool, model, and project"
  homepage "https://codeburn.app/"
  url "https://registry.npmjs.org/codeburn/-/codeburn-0.9.24.tgz"
  sha256 "cd6a68a665c15916f4bb507b361d08ea4a0967821e0a9d594229d4009a4b034b"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "492df4274c31c18d0e0f00fbcad5f23e35df9dbb7ea7b9faaecb3093814c99ef"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    output = shell_output("#{bin}/codeburn report --period today --format json")
    assert_match "\"generated\"", output
    assert_match "\"period\":", output
    assert_match "\"overview\"", output
  end
end
