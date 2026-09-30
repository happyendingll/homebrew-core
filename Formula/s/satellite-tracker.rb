class SatelliteTracker < Formula
  desc "Terminal-based real-time satellite tracking and orbit prediction application"
  homepage "https://github.com/ShenMian/tracker"
  url "https://github.com/ShenMian/tracker/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "2b17176d0fd2ffb1aacd799c77a07c5ca3749061877ec4b7e9f60fcea022c64e"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "abfef3e10e29db613c757e437bae05bb6c6d5c16839aa570c35168149d87dc23"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    require "expect"
    require "pty"

    assert_match version.to_s, shell_output("#{bin}/tracker --version")

    PTY.spawn(bin/"tracker") do |r, w, pid|
      r.winsize = [43, 120]
      r.set_encoding("UTF-8")
      refute_nil r.expect(/\e\[6n/, 10), "expected cursor position query"
      w.write "\e[1;1R"
      refute_nil r.expect("World map", 10), "expected the world map to render"
    ensure
      r.close
      w.close
      Process.kill("KILL", pid)
      Process.wait(pid)
    end
  end
end
