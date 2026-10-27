class Rulesync < Formula
  desc "Unified AI rules management CLI tool"
  homepage "https://github.com/dyoshikawa/rulesync"
  url "https://registry.npmjs.org/rulesync/-/rulesync-42.0.0.tgz"
  sha256 "bf4cf9878bbbd4dcd8073dc012d4b5d611fbb1bf93ba1916b8e0a8d291c42942"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "9415d49097f5bd2a5805bebaaca8c267052a12f90e2283bfd1eae5406e524593"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "9415d49097f5bd2a5805bebaaca8c267052a12f90e2283bfd1eae5406e524593"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "9415d49097f5bd2a5805bebaaca8c267052a12f90e2283bfd1eae5406e524593"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "5d8827cbf8cadfe09c44c16643751524cca6f6f9fbbb6e4563c70e32c2c9337a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "5d8827cbf8cadfe09c44c16643751524cca6f6f9fbbb6e4563c70e32c2c9337a"
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
