class BudgetTracker < Formula
  desc "Feature rich TUI budget tracker app"
  homepage "https://github.com/Feromond/budget-tracker-tui"
  url "https://github.com/Feromond/budget-tracker-tui/archive/refs/tags/v1.8.0.tar.gz"
  sha256 "13cf0bd4d77bea25fb91101962a3c339591586b0d3054903bd212028218903b8"
  license "GPL-3.0-only"
  head "https://github.com/Feromond/budget-tracker-tui.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "6be2494ca5b2644e3294d09a79f014ff8732cd260f3382ba4fcf7967c9b86e08"
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
