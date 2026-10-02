class Lighthouse < Formula
  desc "Rust Ethereum 2.0 Client"
  homepage "https://lighthouse.sigmaprime.io/"
  url "https://github.com/sigp/lighthouse/archive/refs/tags/v8.2.3.tar.gz"
  sha256 "be02f4839b961634d2641fd683f61f6cb5c6fab0452dcc9ef5e132014d626509"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "3a1128aaf7ef3b1979d9914fac0c4bfd189935b4ebdd861c4f8e36635a3f440a"
  end

  depends_on "cmake" => :build
  depends_on "protobuf" => :build
  depends_on "rust" => :build

  uses_from_macos "llvm" => :build

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "zlib-ng-compat"
  end

  def install
    ENV["PROTOC_NO_VENDOR"] = "1"

    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "lighthouse")
  end

  test do
    assert_match "Lighthouse", shell_output("#{bin}/lighthouse --version")

    (testpath/"jwt.hex").write <<~EOS
      d6a1572e2859ba87a707212f0cc9170f744849b08d7456fe86492cbf93807092
    EOS

    http_port = free_port
    args = [
      "--execution-endpoint", "http://localhost:8551",
      "--execution-jwt", "jwt.hex",
      "--allow-insecure-genesis-sync", "--ignore-ws-check", "--http",
      "--http-port=#{http_port}", "--port=#{free_port}"
    ]
    spawn bin/"lighthouse", "beacon_node", *args
    sleep 18

    output = shell_output("curl -sS -XGET http://127.0.0.1:#{http_port}/eth/v1/node/syncing")
    assert_match "is_syncing", output
  end
end
