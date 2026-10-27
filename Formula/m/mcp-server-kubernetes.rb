class McpServerKubernetes < Formula
  desc "MCP Server for kubernetes management commands"
  homepage "https://github.com/Flux159/mcp-server-kubernetes"
  url "https://registry.npmjs.org/mcp-server-kubernetes/-/mcp-server-kubernetes-4.1.10.tgz"
  sha256 "6c492021868e7b51e2887e5525bb77b415b10f7dce356cfb47d3ffa0e4ba96d7"
  license "MIT"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "133756be1bfebeb73226772910f0c357f1eed907a9a911d64c779fecc5cde962"
    sha256 cellar: :any, arm64_tahoe:       "133756be1bfebeb73226772910f0c357f1eed907a9a911d64c779fecc5cde962"
    sha256 cellar: :any, arm64_sequoia:     "133756be1bfebeb73226772910f0c357f1eed907a9a911d64c779fecc5cde962"
    sha256 cellar: :any, arm64_linux:       "cc3411401366d0e1c8b8c4cca1c96bdc3a0b138d1dde2f67e2d4d7600646f509"
    sha256 cellar: :any, x86_64_linux:      "f7b5f47c66fb80adbe4b0aa7b42f6ef667dca381637e703cdaa37a1f0e76996a"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    # Remove incompatible pre-built binaries
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules = libexec/"lib/node_modules/mcp-server-kubernetes/node_modules"
    node_modules.glob("{bare-fs,bare-path,bare-os,bare-url}/prebuilds/*")
                .each { |dir| rm_r(dir) if dir.basename.to_s != "#{os}-#{arch}" }
  end

  test do
    json = <<~JSON
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26"}}
      {"jsonrpc":"2.0","id":2,"method":"tools/list"}
    JSON
    output = pipe_output(bin/"mcp-server-kubernetes", json, 0)
    assert_match "kubectl_get", output
    assert_match "kubectl_describe", output
    assert_match "kubectl_logs", output
  end
end
