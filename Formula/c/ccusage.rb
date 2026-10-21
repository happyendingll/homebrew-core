class Ccusage < Formula
  desc "CLI tool for analyzing Claude Code usage from local JSONL files"
  homepage "https://github.com/ccusage/ccusage"
  url "https://github.com/ccusage/ccusage/archive/refs/tags/v20.0.38.tar.gz"
  sha256 "09100499aa469a02ced756c4cc013ca7b3805b327c45d87864b0fb2724b54dc1"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0e74a35b9871576890d3e2cc88d5bc5bbf03bbf31d64b116cfd8b6c47433670e"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "44a45746ade68022ba5f96867cd978025d62d6f1425cb09ee35daeef442ef9e5"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "809d12af48e706f78e61387142041ade9b4c20d2a0af51c7905e8cf49e495d58"
    sha256 cellar: :any,                 arm64_linux:       "f2e68bce2e4683972451ff9a0b929707b4dd382ef9d8c246fea5a4b5def4c1d6"
    sha256 cellar: :any,                 x86_64_linux:      "6ed57986f0badd1632b82976e8ef211364452403cda887a828da53623747fa67"
  end

  depends_on "rust" => :build

  resource "litellm-pricing-json" do
    url "https://raw.githubusercontent.com/BerriAI/litellm/a31c5230de303d342f62e0e2ecd62af83e5fcd4e/model_prices_and_context_window.json"
    version "a31c5230de303d342f62e0e2ecd62af83e5fcd4e"
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
