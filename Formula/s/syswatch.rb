class Syswatch < Formula
  desc "Cross-platform system diagnostics TUI"
  homepage "https://www.netwatchlabs.com/labs/syswatch"
  url "https://github.com/matthart1983/syswatch/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "86b3b897573b2e7a6772f508be1ff10a2efe2fb591d666ffd5aa182ba55e64cc"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8657404c6090d13d34ee7ae81dacddf0ed422b9ae80b376ead1e47083a923cc8"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "7bd260c2990dcf68e4bc6ca1756d9bd602def131e46aebf60e1ff3cc27de1937"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "3a1eebb6da0ec629df09546523b7836a8eba735811439c847e9462555c3465ff"
    sha256 cellar: :any,                 arm64_linux:       "c53b6d042122c94be6fcadc95414d52de7cbe4e902c6d03bf2db4b0c8955098d"
    sha256 cellar: :any,                 x86_64_linux:      "cf41c3a45eeacac57464938d5a18c7f2295506d4748b2d279491c1975ee9bf40"
  end

  depends_on "rust" => :build

  on_macos do
    depends_on arch: :arm64 # test fails on Intel macOS
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    Open3.popen2("script", "-q", "screenlog.txt") do |input, _, wait_thr|
      input.puts "stty rows 80 cols 130"
      input.puts "env LC_CTYPE=en_US.UTF-8 LANG=en_US.UTF-8 TERM=xterm #{bin}/syswatch"
      sleep 1
      # bring up help dialog
      input.puts "?"
      sleep 1
      input.close
    ensure
      Process.kill("TERM", wait_thr.pid)
    end

    screenlog = (testpath/"screenlog.txt").read.scrub
    assert_match "Services", screenlog
    # match text in help dialog
    assert_match "Procs tab", screenlog
  end
end
