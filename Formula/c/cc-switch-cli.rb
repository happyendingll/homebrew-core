class CcSwitchCli < Formula
  desc "All-in-one assistant tool for Claude Code, Codex, Gemini, OpenCode and OpenClaw"
  homepage "https://github.com/SaladDay/cc-switch-cli"
  url "https://github.com/SaladDay/cc-switch-cli/archive/refs/tags/v5.11.4.tar.gz"
  sha256 "927e28a95d1d9e63849b0591d29171f095dd812abf64241e91e0fc1db440d24b"
  license "MIT"
  head "https://github.com/SaladDay/cc-switch-cli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "b18c6d6a53f9964615a967106b9bfb2d4ff94af6b724c27a008251ec70ffd30c"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args, "--manifest-path", "src-tauri/Cargo.toml"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "src-tauri")
    generate_completions_from_executable(bin/"cc-switch", "completions")
  end

  test do
    ENV["HOME"] = testpath.to_s
    ENV["XDG_CONFIG_HOME"] = (testpath/".config").to_s
    ENV["CODEX_HOME"] = (testpath/".codex").to_s
    ENV["CC_SWITCH_CONFIG_DIR"] = (testpath/"cc-switch").to_s
    ENV["ANTHROPIC_API_KEY"] = "cc-switch-test-api-key"
    ENV["CC_SWITCH_BREW_TEST"] = "1"

    output = shell_output("#{bin}/cc-switch env check -a claude")
    assert_match "ANTHROPIC_API_KEY", output
    assert_match "cc-switch-test-api-key", output
    assert_match "conflict", output
  end
end
