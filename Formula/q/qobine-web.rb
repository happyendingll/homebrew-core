class QobineWeb < Formula
  desc "Server and web based player for Qobuz"
  homepage "https://github.com/SofusA/qobine"
  url "https://github.com/sofusA/qobine/archive/refs/tags/v2026-10-27.tar.gz"
  sha256 "9c8145da3c56d9b1c33ed4d6033b27e564babd1065b4070f519957d13eff518d"
  license "GPL-3.0-only"
  head "https://github.com/sofusa/qobine.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:[._-]\d+)+)$/i)
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "bdce72ab97ff5e9ac9fc6914cb2c279aad9a3f31447426e6196beea01e3001f0"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "alsa-lib"
    depends_on "openssl@4"
  end

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "web-module")
  end

  test do
    _, stdout, = Open3.popen2("#{bin}/qobine-web login")
    assert_match "Login to Qobuz in browser...", stdout.gets("Login to Qobuz in browser...")
  end
end
