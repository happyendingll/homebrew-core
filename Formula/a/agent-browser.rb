class AgentBrowser < Formula
  desc "Browser automation CLI for AI agents"
  homepage "https://agent-browser.dev/"
  url "https://github.com/vercel-labs/agent-browser/archive/refs/tags/v0.38.1.tar.gz"
  sha256 "c49d32065058b06b60ac505ed0b562f469a6ab68566e510f7518166791dac7eb"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "9cb5c65f743527040be6702bffe7a6df8a70470d0443178fff0b1eb6b8adbdb5"
  end

  depends_on "rust" => :build
  depends_on "node"

  deny_network_access! [:postinstall, :test]

  def install
    system "npm", "run", "build:native"
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  def caveats
    <<~EOS
      To complete the installation, run:
        agent-browser install
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/agent-browser --version")

    # Verify session list subcommand works without a browser daemon
    assert_match "No active sessions", shell_output("#{bin}/agent-browser session list")

    # Verify CLI validates commands and rejects unknown ones
    output = shell_output("#{bin}/agent-browser nonexistentcommand 2>&1", 1)
    assert_match "Unknown command", output
  end
end
