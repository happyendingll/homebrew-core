class Rulesync < Formula
  desc "Unified AI rules management CLI tool"
  homepage "https://github.com/dyoshikawa/rulesync"
  url "https://registry.npmjs.org/rulesync/-/rulesync-16.34.2.tgz"
  sha256 "33011ea580a083d31d5323c6c38cb72447375a7d63a83c8678d027cb4910f378"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "cb58e1ea8fb39f3931699a9eaef5d3af820b8a345487cf0cc4ebd2d1c28ae18c"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "cb58e1ea8fb39f3931699a9eaef5d3af820b8a345487cf0cc4ebd2d1c28ae18c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "cb58e1ea8fb39f3931699a9eaef5d3af820b8a345487cf0cc4ebd2d1c28ae18c"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "8eadb0bf3d4975ea418f96702cd9881890466fcda3979683d3e549db174e44df"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "8eadb0bf3d4975ea418f96702cd9881890466fcda3979683d3e549db174e44df"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rulesync --version")

    output = shell_output("#{bin}/rulesync init")
    assert_match "rulesync initialized successfully", output
    assert_match "Project overview and general development guidelines", (testpath/".rulesync/rules/overview.md").read
  end
end
