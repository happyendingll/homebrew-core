class Rulesync < Formula
  desc "Unified AI rules management CLI tool"
  homepage "https://github.com/dyoshikawa/rulesync"
  url "https://registry.npmjs.org/rulesync/-/rulesync-16.37.0.tgz"
  sha256 "d7c37c7ce0a6c9173f292c78d2146316ca15b9cd53d6a4645fd9fb21141b851b"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "861d5d658b18c9b65edd1c618193360295aac6e6fe40e7bc7c1df8379b75323f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "861d5d658b18c9b65edd1c618193360295aac6e6fe40e7bc7c1df8379b75323f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "861d5d658b18c9b65edd1c618193360295aac6e6fe40e7bc7c1df8379b75323f"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "12470f5031afccc8fb2e39ef09335195be54c4758d48890a00ee9e906afc1373"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "12470f5031afccc8fb2e39ef09335195be54c4758d48890a00ee9e906afc1373"
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
