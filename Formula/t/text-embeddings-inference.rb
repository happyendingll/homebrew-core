class TextEmbeddingsInference < Formula
  desc "Blazing fast inference solution for text embeddings models"
  homepage "https://huggingface.co/docs/text-embeddings-inference/quick_tour"
  url "https://github.com/huggingface/text-embeddings-inference/archive/refs/tags/v1.9.4.tar.gz"
  sha256 "9bf7d4f4f149d8bea453a5783803d1db7949d79316f95b1cdf85d1842e8d0380"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "0b0b497a237cc6a61f594a32d0856af6a8150717dc94e58f796a77f7b06a81e6"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    args = (OS.mac? && Hardware::CPU.arm?) ? ["-F", "metal"] : []
    system "cargo", "install", *std_cargo_args(path: "router"), "-F", "candle", *args
  end

  test do
    port = free_port
    spawn bin/"text-embeddings-router", "-p", port.to_s, "--model-id", "sentence-transformers/all-MiniLM-L6-v2"

    data = '{"inputs":"What is Deep Learning?"}'
    header = "Content-Type: application/json"
    retries = "--retry 5 --retry-connrefused"
    assert_match "[[", shell_output("curl 127.0.0.1:#{port}/embed -X POST -d '#{data}' -H '#{header}' #{retries}")
  end
end
