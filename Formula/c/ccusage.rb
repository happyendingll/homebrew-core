class Ccusage < Formula
  desc "CLI tool for analyzing Claude Code usage from local JSONL files"
  homepage "https://github.com/ccusage/ccusage"
  url "https://github.com/ccusage/ccusage/archive/refs/tags/v20.1.2.tar.gz"
  sha256 "9d69db8b290e04526e2cdaa090a9569ce75b1ba020d6ef5e2e07c657ec1db4b1"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "58e7e45fe8ebc3f6ee1441b042244dddcd0571a2fc62a860a2b161204f227a9f"
  end

  depends_on "rust" => :build

  resource "litellm-pricing-json" do
    url "https://raw.githubusercontent.com/BerriAI/litellm/6e3ad131cfb40938f044e006527d02abcf86c9d1/model_prices_and_context_window.json"
    version "6e3ad131cfb40938f044e006527d02abcf86c9d1"
    sha256 "996c36cd33eb92beecd6eab19ef7291d0dcd6f0780fc375283bcd197d88ee62f"

    # Fetch the latest available resource
    livecheck do
      url "https://api.github.com/repos/BerriAI/litellm/branches/main"
      strategy :json do |json|
        json.dig("commit", "sha")
      end
    end
  end

  deny_network_access!

  def fetch
    cd "rust" do
      system "cargo", "fetch", *std_cargo_fetch_args
    end
  end

  def install
    resource("litellm-pricing-json").stage buildpath
    ENV["CCUSAGE_PRICING_JSON_PATH"] = buildpath/"model_prices_and_context_window.json"
    system "cargo", "install", *std_cargo_args(path: "rust/crates/ccusage")
  end

  test do
    ENV["CLAUDE_CONFIG_DIR"] = testpath
    project = testpath/"projects/homebrew"
    project.mkpath
    [["first", 100, 25], ["second", 200, 50]].each do |session, input_tokens, output_tokens|
      (project/"#{session}.jsonl").write JSON.generate(
        timestamp: "2026-05-22T02:34:40.000Z",
        message:   {
          id:    session,
          model: "claude-sonnet-4-20250514",
          usage: { input_tokens:, output_tokens: },
        },
      )
    end

    output = shell_output("#{bin}/ccusage claude daily --offline --json --no-cost --timezone UTC " \
                          "--since 2026-05-22 --until 2026-05-22")
    totals = JSON.parse(output).fetch("totals")
    assert_equal 300, totals.fetch("inputTokens")
    assert_equal 75, totals.fetch("outputTokens")
    assert_equal 375, totals.fetch("totalTokens")
  end
end
