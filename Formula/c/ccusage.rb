class Ccusage < Formula
  desc "CLI tool for analyzing Claude Code usage from local JSONL files"
  homepage "https://github.com/ccusage/ccusage"
  url "https://github.com/ccusage/ccusage/archive/refs/tags/v20.0.32.tar.gz"
  sha256 "0c96e9c79b28554d5ba46a2a5e1332be0e2483e56ed2c11164e03b7082669c7e"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "5837ee4733f25518d185b7f44f4e7109d55163b1064b79a4284761f60ba0a7ec"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a656466e7b92951e6503a922ae071a862bfa9f96c499961e8d88d7d8a0ec45d0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "5ec5157147b247ec9b803856ab253b76f438b7194fa894d8d859293ca43ef6d8"
    sha256 cellar: :any,                 arm64_linux:       "1e941ce31f1dd3bd1bb3916d73c1228a0366f31ed66f56a1f0c11016c7e1d066"
    sha256 cellar: :any,                 x86_64_linux:      "bc66462762d2db93bd35dd773ace8a3cdd911689828a817d5171770ac4e30dd8"
  end

  depends_on "rust" => :build

  resource "litellm-pricing-json" do
    url "https://raw.githubusercontent.com/BerriAI/litellm/aa0279e0a23a4e983141e6df1556df9926a4f3ce/model_prices_and_context_window.json"
    version "aa0279e0a23a4e983141e6df1556df9926a4f3ce"
    sha256 "2f28121f02c9b891078b14eee0d8a0a185c744583a6c5e1f389cc8d39090080d"

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
    assert_match "No usage data found.", shell_output("#{bin}/ccusage 2>&1")
  end
end
