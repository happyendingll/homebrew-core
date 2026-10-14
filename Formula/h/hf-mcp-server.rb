class HfMcpServer < Formula
  desc "MCP Server for Hugging Face"
  homepage "https://github.com/evalstate/hf-mcp-server"
  url "https://registry.npmjs.org/@llmindset/hf-mcp-server/-/hf-mcp-server-0.4.29.tgz"
  sha256 "d97e021f5186586a08114555fcbc98a7787b3a4bf2e400617b0b530e0ff75ecc"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "f18e4e23f4f9a9cf9fd0921871ba69702b7db44a50c62ad12112a2fec2eeca76"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f18e4e23f4f9a9cf9fd0921871ba69702b7db44a50c62ad12112a2fec2eeca76"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f18e4e23f4f9a9cf9fd0921871ba69702b7db44a50c62ad12112a2fec2eeca76"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "4fc841c11198a441cf66bc6314e6d13e3bc4859fbcf5936aa33b79ca0693957c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "4fc841c11198a441cf66bc6314e6d13e3bc4859fbcf5936aa33b79ca0693957c"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    node_modules = libexec/"lib/node_modules/@llmindset/hf-mcp-server/node_modules"
    # Remove incompatible and unneeded Bun binaries.
    rm_r(node_modules.glob("@oven/bun-*"))
    # Remove dev-mode-only bundler and CSS-toolchain prebuilts.
    prebuilts = %w[
      @rollup/rollup
      @rolldown/binding
      @tailwindcss/oxide
      lightningcss
      vite/node_modules/lightningcss
    ]
    rm_r(node_modules.glob("{#{prebuilts.join(",")}}-*"))

    deuniversalize_machos node_modules/"fsevents/fsevents.node" if OS.mac?
  end

  test do
    ENV["TRANSPORT"] = "stdio"
    ENV["DEFAULT_HF_TOKEN"] = "hf_testtoken"

    output_log = testpath/"output.log"
    pid = spawn bin/"hf-mcp-server", [:out, :err] => output_log.to_s
    # The first `node` launch on macOS CI VMs can spend 20+ seconds in dyld
    90.times do
      break if output_log.read.include?("Failed to authenticate with Hugging Face API")

      sleep 1
    end
    assert_match "Failed to authenticate with Hugging Face API", output_log.read
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
