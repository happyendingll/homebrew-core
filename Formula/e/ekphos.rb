class Ekphos < Formula
  desc "Terminal-based markdown research tool inspired by Obsidian"
  homepage "https://ekphos.nostacks.xyz/"
  url "https://github.com/nostacks/ekphos/archive/refs/tags/v0.60.20.tar.gz"
  sha256 "1f2d2e6a55a7870b25a977f02a715390f8f5d93fc2bbd805ca2e3a94a71f8649"
  license "MIT"
  head "https://github.com/nostacks/ekphos.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "258fe288568ea7a3e1dbf4a305a5908f3d9bcc845e7caf865db8e123af3d17cb"
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
    # ekphos is a TUI application
    assert_match version.to_s, shell_output("#{bin}/ekphos --version")

    assert_match "Resetting ekphos configuration...", shell_output("#{bin}/ekphos --reset")
  end
end
