class Evnx < Formula
  desc "Comprehensive CLI tool for managing .env files"
  homepage "https://evnx.dev"
  url "https://github.com/urwithajit9/evnx/archive/refs/tags/v0.10.11.tar.gz"
  sha256 "8359f52dd3d29af6ebf2fa83a776d7fc3a9cdb887823e8bacd6765d176a11385"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "673ce889411fb4b48e63dfe1a6be3a6cc51b984487e6cddccf208c1b4070865b"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "fb97a01279631b386566bbe3c9d1fc92682158dc3fdbb92d3b1b126d0a43381f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "ab18ecf4546b64c6b0d49515ad6dc9a594a3871d8fc66f0de0b9592ab8de1ee1"
    sha256 cellar: :any,                 arm64_linux:       "9f409a1d328f14092dc86a80e2f85c78923103b2736f5d822b8dbdd57d4795d2"
    sha256 cellar: :any,                 x86_64_linux:      "3f0c6c780896fa2b5212bef4e77962164c3910578553fee2ac7fa1d185616eb8"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/evnx --version")

    system bin/"evnx", "init", "--yes"
    assert_path_exists testpath/".env"
    assert_match "All checks passed", shell_output("#{bin}/evnx validate")

    (testpath/".env.example").append_lines "API_KEY="
    assert_match "Validation failed", shell_output("#{bin}/evnx validate 2>&1", 1)
  end
end
