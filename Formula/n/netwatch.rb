class Netwatch < Formula
  desc "Cross-platform realtime network diagnostics TUI"
  homepage "https://www.netwatchlabs.com/labs/netwatch"
  url "https://github.com/matthart1983/netwatch/archive/refs/tags/v0.32.0.tar.gz"
  sha256 "073e49867d79a726d063c14d0c2129f6e5634773150f7c1e4a32068984b48cde"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "f0cabe8556cc769ace21439e68ef665675afc9f984d1765e73de47e3e877e6a3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "b2ccecba764b75717ba010e93767a9e7da035a4010dbb76fefd4d88c733b92a3"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "461d7eb2147bb00001815db00dc9ca2a2f7331a14d606be3b520ca697896bd1f"
    sha256 cellar: :any,                 arm64_linux:       "697f20e17f8af7af2ae8b441397e10f7e5d386d0df414b7a3e670faa5e6cb0d1"
    sha256 cellar: :any,                 x86_64_linux:      "8e97ca845100c7f40ddf0164366f79b3e75f78c0c807fc28ae6edb2af810b7e1"
  end

  depends_on "rust" => :build

  uses_from_macos "libpcap"

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

    screenlog = (testpath/"screenlog.ansi").read
    assert_match "topology", screenlog
    # match text in help dialog
    assert_match "DASHBOARD", screenlog
  end
end
