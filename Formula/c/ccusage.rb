class Ccusage < Formula
  desc "CLI tool for analyzing Claude Code usage from local JSONL files"
  homepage "https://github.com/ccusage/ccusage"
  url "https://github.com/ccusage/ccusage/archive/refs/tags/v20.0.40.tar.gz"
  sha256 "01a8a77d48c3f0f405a2c84ce7ff97a0d6974060851a033ec8172216802fc219"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "3f27dba2b87c1f70b3eac438c68be85a5856c2a5f676329f42efde86fc0e1d20"
  end

  depends_on "rust" => :build

  resource "litellm-pricing-json" do
    url "https://raw.githubusercontent.com/BerriAI/litellm/b6f91a221b6b9df6f8a89ec6f8264ac87d63ff5d/model_prices_and_context_window.json"
    version "b6f91a221b6b9df6f8a89ec6f8264ac87d63ff5d"
    sha256 "91da1a98e194e0d7c436aaf970800c8e734d70cc78027cfe314d5b27dfaf9a4c"

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
