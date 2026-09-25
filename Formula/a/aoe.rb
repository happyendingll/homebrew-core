class Aoe < Formula
  desc "Terminal session manager for AI coding agents"
  homepage "https://github.com/agent-of-empires/agent-of-empires"
  url "https://github.com/agent-of-empires/agent-of-empires/archive/refs/tags/v1.17.1.tar.gz"
  sha256 "81208f6d5f897709fa507c15a543f4fbd2660f82da2a131dc009b6a607a13cfc"
  license "MIT"
  head "https://github.com/agent-of-empires/agent-of-empires.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "fa0321a56c2ea2588b4815c27302a152363bc7233ee6469a59685e80ca7be67b"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "e57b5cfe1bf74d6edb0b3ef13e16ca17b3009b14636be9d88b6ca9ace3a85072"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "80428660cd8d6bf1ee0f848278bfabfa0b1d20a23ac6b24f4ce5953d3723dbee"
    sha256 cellar: :any,                 arm64_linux:       "bc26a1e81da4890294f4ee539800a16bcd54ca7e2f484f90809ab1ead144cca6"
    sha256 cellar: :any,                 x86_64_linux:      "af1b111888858460b3a938c9fd8f2dcf220a98e0037db2e236efb4db43fbb2f1"
  end

  depends_on "node" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@3"
  depends_on "tmux"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "cargo", "install", *std_cargo_args(features: "serve")
    generate_completions_from_executable(bin/"aoe", "completion", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aoe --version")

    system bin/"aoe", "init", testpath
    assert_match "Agent of Empires", (testpath/".agent-of-empires/config.toml").read

    output = shell_output("#{bin}/aoe init #{testpath} 2>&1", 1)
    assert_match "already exists", output

    status = JSON.parse(shell_output("#{bin}/aoe status --json"))
    assert_equal 0, status["total"]

    port = free_port
    pid = fork do
      exec bin/"aoe", "serve", "--port", port.to_s, "--no-auth"
    end
    sleep 2
    assert_match "Agent of Empires", shell_output("curl -s http://127.0.0.1:#{port}")
  ensure
    Process.kill("TERM", pid) if pid
    Process.wait(pid) if pid
  end
end
