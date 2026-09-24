class BudgetTracker < Formula
  desc "Feature rich TUI budget tracker app"
  homepage "https://github.com/Feromond/budget-tracker-tui"
  url "https://github.com/Feromond/budget-tracker-tui/archive/refs/tags/v1.6.1.tar.gz"
  sha256 "a32fc7263d470b6a8d6d7f178a818aa3b46fdb1eef35268cb3c46c8223efc427"
  license "GPL-3.0-only"
  head "https://github.com/Feromond/budget-tracker-tui.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "cdb34e0ed8de7726904ca452940de6a393d3c0d12aacedfac9a295c3582fffce"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked"
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    # budget-tracker is an interactive TUI with no non-interactive commands
    assert_match version.to_s, shell_output("#{bin}/budget-tracker --version")
  end
end
