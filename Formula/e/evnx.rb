class Evnx < Formula
  desc "Comprehensive CLI tool for managing .env files"
  homepage "https://evnx.dev"
  url "https://github.com/urwithajit9/evnx/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "7065528d9225521ad1f1b267aeeee77c476849f419109a79097e90b30c56c3f4"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "c2a2800618f62ef8837f032176f4622dc605a2f641d214d5310515e1d1a32492"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/evnx --version")

    system bin/"evnx", "init", "--yes"
    assert_path_exists testpath/".env"
    assert_match "Validation failed", shell_output("#{bin}/evnx validate 2>&1", 1)
  end
end
