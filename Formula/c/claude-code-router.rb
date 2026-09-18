class ClaudeCodeRouter < Formula
  desc "Tool to route Claude Code requests to different models and customize any request"
  homepage "https://musistudio.github.io/claude-code-router/"
  url "https://registry.npmjs.org/@musistudio/claude-code-router/-/claude-code-router-3.1.1.tgz"
  sha256 "3a7cb06f392090ad77fa9174ed412c4e408b926c96bcb511b62140bd6bebba5a"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "a62c4fe25360eb18cc1db22b85884cd75a47d7bbd966d0ecc157c32700f1a0f3"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args

    # better-sqlite3's prebuilt binary is skipped by the sandbox, so build it via node-gyp.
    cd libexec/"lib/node_modules/@musistudio/claude-code-router/node_modules/better-sqlite3" do
      system "npm", "run", "build-release"
    end

    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    (testpath/".claude-code-router/config.json").write <<~JSON
      {
        "Providers": [
          {
            "name": "test",
            "api_base_url": "https://api.test.local/v1/chat/completions",
            "api_key": "sk-test",
            "models": ["test-model"]
          }
        ],
        "Router": { "default": "test,test-model" }
      }
    JSON

    output_log = testpath/"output.log"
    spawn bin/"ccr", "start", "--port", free_port.to_s, "--no-gateway", [:out, :err] => output_log.to_s

    30.times do
      break if output_log.exist? && output_log.read.include?("CCR service started")

      sleep 1
    end

    assert_match "CCR service stopped", shell_output("#{bin}/ccr stop")
  end
end
