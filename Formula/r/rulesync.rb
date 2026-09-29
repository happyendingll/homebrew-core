class Rulesync < Formula
  desc "Unified AI rules management CLI tool"
  homepage "https://github.com/dyoshikawa/rulesync"
  url "https://registry.npmjs.org/rulesync/-/rulesync-23.0.0.tgz"
  sha256 "382b78eba6ff318baabae28f913f08b11dd183a9c19205e7d1be182ad59b2d4e"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "f5a35445ff826ad74aa45d71494468140da559bbc57ad4e38ed383753f33d6cf"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f5a35445ff826ad74aa45d71494468140da559bbc57ad4e38ed383753f33d6cf"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f5a35445ff826ad74aa45d71494468140da559bbc57ad4e38ed383753f33d6cf"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "75561d962cb939a887aad6338bc46c6e59260d6333f9b7c26562619f96d4a1b1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "75561d962cb939a887aad6338bc46c6e59260d6333f9b7c26562619f96d4a1b1"
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
