class RvR < Formula
  desc "Declarative R package manager"
  homepage "https://a2-ai.github.io/rv-docs/"
  url "https://github.com/A2-ai/rv/archive/refs/tags/v0.23.2.tar.gz"
  sha256 "2be443428dff4122dea7df9f62b62167a01dd67675e72e9431b536699e9c8a05"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "93f4e3d1ecf314fe2a7e1f028b799ed3474fa46c139eff92bcfd795ce925a833"
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
