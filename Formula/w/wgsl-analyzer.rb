class WgslAnalyzer < Formula
  desc "Language server implementation for WGSL and WESL"
  homepage "https://wgsl-analyzer.github.io"
  url "https://github.com/wgsl-analyzer/wgsl-analyzer/archive/refs/tags/2026-09-30.tar.gz"
  sha256 "656ca21fc1e37bc8c1bab25c434b315ba910d4f6702ee6905e20e9860e8f482c"
  license any_of: ["Apache-2.0", "MIT"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "2c061e64c656a02599c8ab80032321508449430a92e492a1fa84129ea3b18240"
  end

  depends_on "rust" => :build

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
