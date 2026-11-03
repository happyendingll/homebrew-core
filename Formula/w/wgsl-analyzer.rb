class WgslAnalyzer < Formula
  desc "Language server implementation for WGSL and WESL"
  homepage "https://wgsl-analyzer.github.io"
  url "https://github.com/wgsl-analyzer/wgsl-analyzer/archive/refs/tags/2026-11-02.tar.gz"
  sha256 "0ef0ec3f9a2cc4dc90bb6323b3b851e7d287895304cd8aaa95bd1c39ac1d1b23"
  license any_of: ["Apache-2.0", "MIT"]

  livecheck do
    url :stable
    regex(/v?(\d+(:?[._-]\d+)+)/i)
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "0183a16e603d90af3b1c099b080f213c2f39f1a06a12b526fbc4e30ec49622b7"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/wgsl-analyzer")
  end

  test do
    input = <<~EOF
      Content-Length: 132\r\n\r
      {
        "jsonrpc":"2.0",
        "id":1,
        "method":"initialize",
        "params": {
          "rootUri": "file:/dev/null",
          "capabilities": {}
        }
      }
      Content-Length: 64\r\n\r
      {
        "jsonrpc":"2.0",
        "method":"initialized",
        "params": {}
      }
      Content-Length: 74\r\n\r
      {
        "jsonrpc":"2.0",
        "id": 1,
        "method":"shutdown",
        "params": null
      }
      Content-Length: 57\r\n\r
      {
        "jsonrpc":"2.0",
        "method":"exit",
        "params": {}
      }
    EOF

    output = /Content-Length: \d+\r\n\r\n/

    assert_match output, pipe_output(bin/"wgsl-analyzer", input, 0)
  end
end
