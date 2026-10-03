class Netwatch < Formula
  desc "Cross-platform realtime network diagnostics TUI"
  homepage "https://www.netwatchlabs.com/labs/netwatch"
  url "https://github.com/matthart1983/netwatch/archive/refs/tags/v0.35.1.tar.gz"
  sha256 "6ae6a076ed86a74a66efd766c61c2e5196f94a1acda663c97487cf32f2ddbb8e"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "629eed2b3058f6faab720c3dfdafa65b0ae9a13dcd5b290e5b2a67173d79682d"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "8564af1f4c25bf346627d828005d53663213fda20d3efcee5da8a57deb5572c8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "793d2bcdab27996ef6046de56ad74d70c10a531fe7e5d1f2f372b052e8188e14"
    sha256 cellar: :any,                 arm64_linux:       "638250beabb833322a2c868439c11cfaca9b368a80f73f5ead4403c4d28249b6"
    sha256 cellar: :any,                 x86_64_linux:      "44a54f4668b593774124dd75b70902a4b570602b51722a905be26b23bae1e983"
  end

  depends_on "rust" => :build

  uses_from_macos "libpcap"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    Open3.popen2("script", "-q", "screenlog.ansi") do |input, _, wait_thr|
      input.puts "stty rows 80 cols 130"
      input.puts "env LC_CTYPE=en_US.UTF-8 LANG=en_US.UTF-8 TERM=xterm #{bin}/netwatch"
      sleep 1
      # bring up help dialog
      input.puts "?"
      sleep 1
      input.close
    ensure
      Process.kill("TERM", wait_thr.pid)
    end

    screenlog = (testpath/"screenlog.ansi").binread
    assert_match "topology", screenlog
    # match text in help dialog
    assert_match "DASHBOARD", screenlog
  end
end
