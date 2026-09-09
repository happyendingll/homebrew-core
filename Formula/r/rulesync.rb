class Rulesync < Formula
  desc "Unified AI rules management CLI tool"
  homepage "https://github.com/dyoshikawa/rulesync"
  url "https://registry.npmjs.org/rulesync/-/rulesync-16.25.0.tgz"
  sha256 "3cef173bd519314b505ecc236dc1940f7f1fc22d9745142f7011c06637eee551"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e3a4a7d84ba39abbcda46be39095cec9d81d6e167c5d6bb4e40e4b9ba0da5d38"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e3a4a7d84ba39abbcda46be39095cec9d81d6e167c5d6bb4e40e4b9ba0da5d38"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e3a4a7d84ba39abbcda46be39095cec9d81d6e167c5d6bb4e40e4b9ba0da5d38"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "db44b2d76f0d71b11af7a465e932cfe3035c6451845f8043428a51e957b0ba55"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "db44b2d76f0d71b11af7a465e932cfe3035c6451845f8043428a51e957b0ba55"
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
