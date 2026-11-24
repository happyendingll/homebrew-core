class Proxelar < Formula
  desc "Man-in-the-Middle proxy for HTTP/HTTPS traffic"
  homepage "https://proxelar.micheletti.io"
  url "https://github.com/emanuele-em/proxelar/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "6570666545c10cdd954c2b39961087c825ffc54c8bbbe794cad1b012f4629c36"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "96903fd5f9bc0f882833e6c867aa2b246c26df349abb64d993905e5607d0535e"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "lua"
  depends_on "openssl@4"

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["OPENSSL_DIR"] = dep("openssl").opt_prefix
    features = ["scripting"]
    inreplace "proxyapi/Cargo.toml", "lua54", "lua55" # Allow bindings for the latest Lua version
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "proxelar-cli", features:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/proxelar --version")

    port = free_port
    with_test_process(bin/"proxelar", "--interface", "terminal", "--port", port.to_s, "--ca-dir", testpath) do
      sleep 2
      output = shell_output("curl --silent --max-time 5 --proxy http://127.0.0.1:#{port} http://example.com/")
      assert_match "Example Domain", output
    end
  end
end
