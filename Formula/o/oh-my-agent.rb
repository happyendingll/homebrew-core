class OhMyAgent < Formula
  desc "Portable multi-agent harness for .agents-based skills and workflows"
  homepage "https://firstfluke.com/oh-my-agent/"
  url "https://registry.npmjs.org/oh-my-agent/-/oh-my-agent-14.13.1.tgz"
  sha256 "041d14e23df5854f0222d754c37e4eed7ee70d2293c11686dd7c481ceea2c228"
  license "MIT"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "1adba0db76b4470385ca7a6b538a63050c7c8abf93474e4f3cb3256838a29de7"
    sha256 cellar: :any, arm64_tahoe:       "e5c1fd035f9e2aa684e84dcfe4d2cf05fba6014a884f1a4e8152d97dfa427950"
    sha256 cellar: :any, arm64_sequoia:     "6d0cea5928535a3848c7a77bf77d69b91aa7fb6d6a495e41a62552566be0d968"
    sha256 cellar: :any, arm64_linux:       "4309e8c5f90bbe473b2bb6b2b84a65a78c13bb02d47f76eb690e31b4837f5052"
    sha256 cellar: :any, x86_64_linux:      "e85068df8b912a5fe11469dd3e77cf2361414748d2a8f57b9bf83899075abac9"
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
