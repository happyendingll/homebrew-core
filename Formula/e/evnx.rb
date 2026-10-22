class Evnx < Formula
  desc "Comprehensive CLI tool for managing .env files"
  homepage "https://evnx.dev"
  url "https://github.com/urwithajit9/evnx/archive/refs/tags/v0.10.15.tar.gz"
  sha256 "ee2f298403d4abbb156f0113de8c7fd85b4599eb8bf095f5bd284b0c51c43dd3"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "1e81310253897a979ef5dbb24efa98b96b3785b4fe0c99a71a8a7ab68462eb12"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "085070dd755537bea4031aa5bd90e5eb6e2bcafe101ca84b56ae243aeb9d2796"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "0c0f6f8b7ad9ff6ebdb104ad96144babb513121ea64b180ce0c1b5ee5d575511"
    sha256 cellar: :any,                 arm64_linux:       "f2c8e69b5fbeb3ee9bde9aa204d9400b7db657b5c115fff5d3783f640f19943e"
    sha256 cellar: :any,                 x86_64_linux:      "ffd800644a32ed0c52d0b01ea2ca8b29d35b780b4c4e4e112a64d643b2fa020c"
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
