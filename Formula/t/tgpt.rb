class Tgpt < Formula
  desc "AI Chatbots in terminal without needing API keys"
  homepage "https://github.com/aandrew-me/tgpt"
  url "https://github.com/aandrew-me/tgpt/archive/refs/tags/v2.15.0.tar.gz"
  sha256 "208f8d96ef1b1af85c765d3dde45842fd7df18936fb4e121d52538d0da1be032"
  license "GPL-3.0-only"
  head "https://github.com/aandrew-me/tgpt.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "dbab4c21630b3432eabc19158ac3170a317ef3ad8e65e0346527e32dfb16815e"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "libx11"
  end

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tgpt --version")

    # The free default providers keep changing their access rules, so query a local port with nothing listening
    url = "http://127.0.0.1:#{free_port}/v1/chat/completions"
    output = shell_output("#{bin}/tgpt --quiet --provider ollama --url #{url} 'What is 1+1' 2>&1", 1)
    assert_match "connect: connection refused", output
  end
end
