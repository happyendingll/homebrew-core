class AgentBrowser < Formula
  desc "Browser automation CLI for AI agents"
  homepage "https://agent-browser.dev/"
  url "https://github.com/vercel-labs/agent-browser/archive/refs/tags/v0.45.0.tar.gz"
  sha256 "5e2a2e2edd9ae87a9f92da34ecee02ef4299ee1c0a8cbebae1b7d63c561d6ba9"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "fa75c1954653c0ee91b293c429f141dc363f5ca778253096f4e51fcf8171199d"
  end

  depends_on "pnpm@11" => :build
  depends_on "rust" => :build
  depends_on "node"

  allow_network_access! :build

  def install
    # Build the dashboard before Cargo embeds it in the native CLI.
    system "pnpm", "install", "--frozen-lockfile", "--filter", "dashboard", "--ignore-scripts"
    # Homebrew places HOME inside the workspace, so Next needs an explicit root.
    inreplace "packages/dashboard/next.config.ts", '  output: "export",',
              "  output: \"export\",\n  turbopack: { root: #{buildpath.to_s.inspect} },"
    system "pnpm", "run", "build:dashboard"

    # Install the source-built CLI instead of npm's prebuilt platform packages.
    system "cargo", "install", *std_cargo_args(path: "cli", root: libexec)
    libexec.install "skills", "skill-data"
    bin.install_symlink libexec/"bin/agent-browser"
  end

  def caveats
    <<~EOS
      To complete the installation, run:
        agent-browser install
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/agent-browser --version")

    sessions = JSON.parse(shell_output("#{bin}/agent-browser --json session list"))
    assert_equal true, sessions["success"]
    assert_empty sessions.dig("data", "sessions")

    skill = JSON.parse(shell_output("#{bin}/agent-browser --json skills get core"))
    assert_equal true, skill["success"]
    assert_equal "core", skill["data"].first["name"]

    shell_output("#{bin}/agent-browser nonexistentcommand 2>&1", 1)
  end
end
