class OhMyAgent < Formula
  desc "Portable multi-agent harness for .agents-based skills and workflows"
  homepage "https://firstfluke.com/oh-my-agent/"
  url "https://registry.npmjs.org/oh-my-agent/-/oh-my-agent-14.7.9.tgz"
  sha256 "f0b38256bbb17fbb22dfc8ffd0d67286ddf964a4663e98f01d24662847e4ca0f"
  license "MIT"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "c4cc21b44b2b4a6ad94dc6b25a1ee67a61600b6118c48b4b69c27243db244c7d"
    sha256 cellar: :any, arm64_tahoe:       "f822fd767e290cd487b436fd7e50e5605040b34f90ab50a7f6b5644643e027d0"
    sha256 cellar: :any, arm64_sequoia:     "7472939f95deff3cc0cc4245d50548947f7e75ac760e667dcdda528be309245d"
    sha256 cellar: :any, arm64_linux:       "687138676f1c470378b5f8242424e5adc8e3a174a469df9c6e28498662e2bc51"
    sha256 cellar: :any, x86_64_linux:      "6cda1fbd9d6148ae6177560bb0f585060917e4a9e5f770b4965c9a882fedb038"
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
