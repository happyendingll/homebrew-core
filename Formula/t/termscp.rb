class Termscp < Formula
  desc "Feature rich terminal file transfer and explorer"
  # https://termscp.veeso.dev is not accessible, upstream bug report, https://github.com/veeso/termscp/issues/420
  homepage "https://termscp.rs"
  license "MIT"
  head "https://github.com/veeso/termscp.git", branch: "main"

  stable do
    url "https://github.com/veeso/termscp/archive/refs/tags/v1.2.1.tar.gz"
    sha256 "378b06607669edd6fdbcf1f3e040928b4a5e41c3792334d8b140270bd9afe0b7"

    # Update `Cargo.lock` file
    patch do
      url "https://github.com/veeso/termscp/commit/0c7383af6f6471c25894d411c48c3106c9da0621.patch?full_index=1"
      sha256 "d43dabfa4d7d1ef3dcb0e15193a52b87479b08cfef9e4fc89262ca9b0b1011b2"
      type :backport
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "40c9e5062cd332d1c6726f03c9df4188b4c2bd8b342662836f4f35bd676101d2"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"
  depends_on "samba"

  on_linux do
    depends_on "dbus"
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@4")

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
