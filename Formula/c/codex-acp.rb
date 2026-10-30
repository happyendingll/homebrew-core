class CodexAcp < Formula
  desc "ACP server that exposes Codex CLI functionality for ACP-compatible clients"
  homepage "https://github.com/agentclientprotocol/codex-acp"
  url "https://registry.npmjs.org/@agentclientprotocol/codex-acp/-/codex-acp-2.4.0.tgz"
  sha256 "86bd1974cc93c275ba0d5088bc1ac2ce52907f48003e26e2c6736a5f77ab2bf4"
  license "Apache-2.0"
  head "https://github.com/agentclientprotocol/codex-acp.git", branch: "main"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "82920f7c36cb5cf56f60606301329478ea65aebc3abe53697220f3e555144ba4"
    sha256 cellar: :any, arm64_tahoe:       "82920f7c36cb5cf56f60606301329478ea65aebc3abe53697220f3e555144ba4"
    sha256 cellar: :any, arm64_sequoia:     "82920f7c36cb5cf56f60606301329478ea65aebc3abe53697220f3e555144ba4"
    sha256 cellar: :any, arm64_linux:       "d9bc4e873498342c898452c2052f8416bf65cf26340f815b597be937700ec7aa"
    sha256 cellar: :any, x86_64_linux:      "bce5c2fd0134eda8ac0daedb2d63984f9ca637eeee99e02a0e4efd11ae2e697b"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
    rm libexec.glob("lib/node_modules/**/codex-resources/zsh/bin/zsh") if OS.linux?
  end

  test do
    json = <<~JSON
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":1}}
    JSON

    Open3.popen3(bin/"codex-acp") do |stdin, stdout, _e, w|
      stdin.write json
      sleep 3
      output = stdout.readline
      assert_match("\"protocolVersion\":1", output)
      assert_match("\"agentInfo\":{\"name\":\"@agentclientprotocol/codex-acp\"", output)
      Process.kill("KILL", w.pid)
    end
  end
end
