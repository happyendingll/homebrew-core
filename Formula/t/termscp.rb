class Termscp < Formula
  desc "Feature rich terminal file transfer and explorer"
  # https://termscp.veeso.dev is not accessible, upstream bug report, https://github.com/veeso/termscp/issues/420
  homepage "https://termscp.rs"
  url "https://github.com/veeso/termscp/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "fe35ae14d72a3e40f43532c44ffbced9667ca515c82b93ce2b4398b768fd1113"
  license "MIT"
  head "https://github.com/veeso/termscp.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "6a671376dad1bacd6aacb3f1c447082fa87916b6255d80fc4a68b150a0148b4a"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@3"
  depends_on "samba"

  on_linux do
    depends_on "dbus"
    depends_on "zlib-ng-compat"
  end

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@3")

    system "cargo", "install", *std_cargo_args
  end

  test do
    require "pty"
    PTY.spawn(bin/"termscp", "config") do |_r, _w, pid|
      sleep 10
      Process.kill 9, pid
    end
  end
end
