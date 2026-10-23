class Rulesync < Formula
  desc "Unified AI rules management CLI tool"
  homepage "https://github.com/dyoshikawa/rulesync"
  url "https://registry.npmjs.org/rulesync/-/rulesync-40.1.0.tgz"
  sha256 "9e46d8f4289c26b4d784bc84958c0efe633300b8690b779822e450caa761b61e"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "db9efe7f63eb37a80db72658d1550e6f9a342da4f0267c6123b3dbeeb582b86c"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "db9efe7f63eb37a80db72658d1550e6f9a342da4f0267c6123b3dbeeb582b86c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "db9efe7f63eb37a80db72658d1550e6f9a342da4f0267c6123b3dbeeb582b86c"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "31c4dfdac2d13ff8df4d334772cf3e99ed7e4854e5d0ccf299a0f09e08c50e92"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "31c4dfdac2d13ff8df4d334772cf3e99ed7e4854e5d0ccf299a0f09e08c50e92"
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
