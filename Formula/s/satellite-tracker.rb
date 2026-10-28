class SatelliteTracker < Formula
  desc "Terminal-based real-time satellite tracking and orbit prediction application"
  homepage "https://github.com/ShenMian/tracker"
  url "https://github.com/ShenMian/tracker/archive/refs/tags/v0.2.2.tar.gz"
  sha256 "f09223c10ae65d8b6e92a6ce2fac6489c6f0f110fb014514988160ef47f2cd1a"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "509a5181ec3ed025427c471b27765ea4ac196ac4f88a80bd87f13b90af4e6a38"
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

    (testpath/".config/tracker/config.toml").write <<~TOML
      [world_map]
      lon_delta_deg = 0
    TOML

    PTY.spawn(bin/"tracker") do |r, w, pid|
      r.winsize = [43, 120]
      r.set_encoding("UTF-8")
      refute_nil r.expect("lon_delta_deg must be a finite number greater than 0, got 0", 10),
        "expected invalid configuration to be rejected"
      refute_nil r.expect("Using default configuration.", 10), "expected fallback to default configuration"
      refute_nil r.expect(/\e\[6n/, 10), "expected cursor position query"
    ensure
      r.close
      w.close
      Process.kill("KILL", pid)
      Process.wait(pid)
    end
  end
end
