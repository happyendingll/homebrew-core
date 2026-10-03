class OhMyAgent < Formula
  desc "Portable multi-agent harness for .agents-based skills and workflows"
  homepage "https://firstfluke.com/oh-my-agent/"
  url "https://registry.npmjs.org/oh-my-agent/-/oh-my-agent-15.0.11.tgz"
  sha256 "dfbe39c34f0c313dfbd7d3390118f883a67606bcb5dac4c47356e5726e436429"
  license "MIT"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "3bd3b8306c04fe801fe357ee22f7e68cb6e59dbd2098eb6cc100caca6dce0fdd"
    sha256 cellar: :any, arm64_tahoe:       "00559f25fe88290c278ce2c69bd8377691282046b59f0e573a11113027347c2d"
    sha256 cellar: :any, arm64_sequoia:     "704e570e223038a132280118800c98f4017887709cf894ef4c7836d2e9084bd1"
    sha256 cellar: :any, arm64_linux:       "6e35479f33238239217f73195f36eedd8f4ceccc34bfa088e5a7e5f95ac6b365"
    sha256 cellar: :any, x86_64_linux:      "c31884f83080dccf0fea29d783b2c1d631f8e1af1b194a5f9c1643b811c2fc9b"
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
