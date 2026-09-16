class AgentBrowser < Formula
  desc "Browser automation CLI for AI agents"
  homepage "https://agent-browser.dev/"
  url "https://github.com/vercel-labs/agent-browser/archive/refs/tags/v0.38.0.tar.gz"
  sha256 "93095fef92911656aa89172ffad150420dd976009bff6dc685936235ac61010c"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "018681847adedef16c4c8843fd50e34604c74a62b1e2d5e8d8b589bb0a811601"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "bc1a64db12584c5bec5e412186355802d7fc24604620554221b2fa49d3a7768a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "ae67f34bed0eda4fc8c613b9b82a700c8cd96a8838043db00b15a673f108f0b3"
    sha256 cellar: :any,                 arm64_linux:       "359d4afa56a52e4a9a29bbc58372fbc10081cc3afdcf00bba78f7bbcb8ec6c91"
    sha256 cellar: :any,                 x86_64_linux:      "8e1de740ef3a177c7b65199bc916ceab3c44898977298196827e1d9579941d45"
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
