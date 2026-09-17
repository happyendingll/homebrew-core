class Rulesync < Formula
  desc "Unified AI rules management CLI tool"
  homepage "https://github.com/dyoshikawa/rulesync"
  url "https://registry.npmjs.org/rulesync/-/rulesync-16.34.1.tgz"
  sha256 "075886e131f5163063676aac02a8f545269cdc81d2179dc83dc8654cb91a7839"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "f48f2aa2c518c15c08f6d9be826e41cad1bd38d5c927ea0dd5ae49519ef88dd4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f48f2aa2c518c15c08f6d9be826e41cad1bd38d5c927ea0dd5ae49519ef88dd4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f48f2aa2c518c15c08f6d9be826e41cad1bd38d5c927ea0dd5ae49519ef88dd4"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "a4b52f4795b7ef7d9ec9ecedc3e3e5e36dd270cc9549da86ec49b7ef219159cf"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "a4b52f4795b7ef7d9ec9ecedc3e3e5e36dd270cc9549da86ec49b7ef219159cf"
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
