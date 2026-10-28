class Rulesync < Formula
  desc "Unified AI rules management CLI tool"
  homepage "https://github.com/dyoshikawa/rulesync"
  url "https://registry.npmjs.org/rulesync/-/rulesync-43.1.0.tgz"
  sha256 "f839b78547324679f1dde210731db4fb3a840244fea27a5297c0403b7672d885"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "78ca7349601d691ecabbfd04d30b5652432931f71e5fb23572b5d86e3736d029"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "78ca7349601d691ecabbfd04d30b5652432931f71e5fb23572b5d86e3736d029"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "78ca7349601d691ecabbfd04d30b5652432931f71e5fb23572b5d86e3736d029"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "abe7d08974bfc9e06485534e317b916af0cfb8c55a301358d2c5814edfeca05b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "abe7d08974bfc9e06485534e317b916af0cfb8c55a301358d2c5814edfeca05b"
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
