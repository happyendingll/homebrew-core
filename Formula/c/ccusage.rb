class Ccusage < Formula
  desc "CLI tool for analyzing Claude Code usage from local JSONL files"
  homepage "https://github.com/ccusage/ccusage"
  url "https://github.com/ccusage/ccusage/archive/refs/tags/v20.0.23.tar.gz"
  sha256 "24c16f14ee72801ac913d751b891a8eb9dde6ef85ee5302c1e26643a745efa84"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "9b6ea4185e8ac3223c8f0950b1f28dc8718a2c8727ae5370a1daca54128f9f3b"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "rust/crates/ccusage", features: "fetch-litellm-pricing")
  end

  test do
    assert_match "No usage data found.", shell_output("#{bin}/ccusage 2>&1")
  end
end
