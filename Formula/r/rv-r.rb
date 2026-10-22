class RvR < Formula
  desc "Declarative R package manager"
  homepage "https://a2-ai.github.io/rv-docs/"
  url "https://github.com/A2-ai/rv/archive/refs/tags/v0.23.3.tar.gz"
  sha256 "2237ca6b54ff40dcc9cf4ce5ad000d197f34df7631fa5d143e0f734866f3d230"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "34ec00a9b39201d3e8d9313933f24d1b2b835bdfcfa9636fdf85080049c87989"
  end

  depends_on "rust" => :build
  depends_on "r" => :test

  conflicts_with "rv", because: "both install `rv` binary"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(features: "cli")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rv --version")
    system bin/"rv", "init"
    assert_path_exists "rproject.toml"
  end
end
