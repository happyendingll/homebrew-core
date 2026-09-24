class OhMyAgent < Formula
  desc "Portable multi-agent harness for .agents-based skills and workflows"
  homepage "https://firstfluke.com/oh-my-agent/"
  url "https://registry.npmjs.org/oh-my-agent/-/oh-my-agent-15.0.0.tgz"
  sha256 "9096065373bfd751039b6bf827a8bcefae78cc757f40deaecf2126d0d00cfc97"
  license "MIT"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "33ecd43bada52bfc11ea29071effddf4c1be2ba9ef1efcad550250f8c2d3600e"
    sha256 cellar: :any, arm64_tahoe:       "0aa4bf3f915fd985a4638d5e4a0a7d503e5cd7a68cbca9251254499593d67bf3"
    sha256 cellar: :any, arm64_sequoia:     "57aa36568021d03dd7a2a7912440b2a1ff1a2b0e210aa0fc25391468738ae94a"
    sha256 cellar: :any, arm64_linux:       "2fb0f6a5e0da893420fcfb0f84aad8c7922f98a15449c26ce77a4397e3b97063"
    sha256 cellar: :any, x86_64_linux:      "136218d0fdc665450f19deaa2c1c5ac7b19c457d69fe4163a1611f06353ef600"
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
