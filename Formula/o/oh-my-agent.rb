class OhMyAgent < Formula
  desc "Portable multi-agent harness for .agents-based skills and workflows"
  homepage "https://firstfluke.com/oh-my-agent/"
  url "https://registry.npmjs.org/oh-my-agent/-/oh-my-agent-14.9.0.tgz"
  sha256 "b106a06e6e483deb9f75e478add75b90cf4cb6c808a6d11543ba1633c359f58f"
  license "MIT"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "d50145df808add8261fa3dcdd8ca3af62761209a547fa109dff7cedaaa10e8a1"
    sha256 cellar: :any, arm64_tahoe:       "deb6cb50620b9508c4725ed55a44910cb67be5ea5d578625d80a21f3229e2f44"
    sha256 cellar: :any, arm64_sequoia:     "3c4ba78c2e842fdcb1a91497774702abcede43b0659afc326b18a96927347900"
    sha256 cellar: :any, arm64_linux:       "45e80e5a137403a63973ceb5612569c9b7ee0dc17b0ca28b87a6e28ccad9f1ea"
    sha256 cellar: :any, x86_64_linux:      "6fe2f08fc987532d3b4fcd08cbf6995c8c6b5e098c4b97bb5fdacf159407ded1"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args

    node_modules = libexec/"lib/node_modules/oh-my-agent/node_modules"
    # Remove incompatible pre-built `bare-fs`/`bare-os`/`bare-path`/`bare-url` binaries
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules.glob("{bare-fs,bare-os,bare-path,bare-url}/prebuilds/*")
                .each { |dir| rm_r(dir) if dir.basename.to_s != "#{os}-#{arch}" }

    rm_r(node_modules.glob("better-sqlite3/prebuilds/*"))
    cd(node_modules/"better-sqlite3") { system "npm", "run", "build-release" }

    bin.install_symlink Dir[libexec/"bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/oh-my-agent --version")

    output = JSON.parse(shell_output("#{bin}/oh-my-agent memory init --json"))
    assert_empty output["updated"]
    assert_path_exists testpath/".agents/state/memories/orchestrator-session.md"
    assert_path_exists testpath/".agents/state/memories/task-board.md"
  end
end
