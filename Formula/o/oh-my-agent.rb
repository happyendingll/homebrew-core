class OhMyAgent < Formula
  desc "Portable multi-agent harness for .agents-based skills and workflows"
  homepage "https://firstfluke.com/oh-my-agent/"
  url "https://registry.npmjs.org/oh-my-agent/-/oh-my-agent-20.20.1.tgz"
  sha256 "d0cfa0e27d9d55853d890964ac99bc26df6496da5b46967826b173a0a09df3a6"
  license "MIT"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "915b4c861c1359f75d6b97cd2d1088bd7f405379f3c1881165ca22abf5661402"
    sha256 cellar: :any, arm64_tahoe:       "1d97bed13925711e04384ee2128c598df1e13524d829200a484190999e4c2ec1"
    sha256 cellar: :any, arm64_sequoia:     "5900f4e4f44d3a57dad8d317ab14fdee6bb0efaf19810025e4d3c95f6b99e5b4"
    sha256 cellar: :any, arm64_linux:       "bb2904eba9887b78e2b51b6cbeadb2b70f1962033ba103bc9af296fc4b6f0d47"
    sha256 cellar: :any, x86_64_linux:      "a63bd536923cec0e34090d8ab031b9f081cda01595935458b2bb002b0717807b"
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
