class Websocat < Formula
  desc "Command-line client for WebSockets"
  homepage "https://github.com/vi/websocat"
  url "https://github.com/vi/websocat/archive/refs/tags/v1.14.1.tar.gz"
  sha256 "5c976c535800ca635b72839fe49d0fe4ad2479db8744c5a00f0cf911e4832e2d"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "577a043e3ed1a3e2978dc5259b1fb405199f9e2bfebe31675a2383fb7b8e157b"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  # Backport support for OpenSSL 4
  patch do
    url "https://github.com/vi/websocat/commit/aa8fadaa212c2287067b722d4440b4f4118b39ea.patch?full_index=1"
    sha256 "5957930d4c4df80305b3ac15412f7be18438025132d1f77208d77499eb0e6f0d"
    type :backport
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(features: "ssl")
  end

  test do
    system bin/"websocat", "-t", "literal:qwe", "assert:qwe"
  end
end
