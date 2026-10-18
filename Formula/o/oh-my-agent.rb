class OhMyAgent < Formula
  desc "Portable multi-agent harness for .agents-based skills and workflows"
  homepage "https://firstfluke.com/oh-my-agent/"
  url "https://registry.npmjs.org/oh-my-agent/-/oh-my-agent-20.5.0.tgz"
  sha256 "dcbc3547820047cb121e33844453d748fd2796348795c64003130c06d2cb7b05"
  license "MIT"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "c475d6654c6bd00549d1383e9c262df88f38dc739b5f1f2ce304126732ff7b78"
    sha256 cellar: :any, arm64_tahoe:       "69a66895b066580f9ae30f3615bdc60249520e98e04e8f79a5b0e07e8900aa21"
    sha256 cellar: :any, arm64_sequoia:     "295ce26b7b1e36837472dee271412d7e3e416308749ee60b801b9c8f7663fd68"
    sha256 cellar: :any, arm64_linux:       "7a7a242b63278307bdee097bb0537d18264096d003793a1a03789d02d777e799"
    sha256 cellar: :any, x86_64_linux:      "828e1faf2fa5e31bf65d3c5f0d41b863ff08bbb4cba5d8cb9829cee3fa100204"
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
