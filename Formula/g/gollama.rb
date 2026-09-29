class Gollama < Formula
  desc "Go manage your Ollama models"
  homepage "https://smcleod.net"
  url "https://github.com/sammcj/gollama/archive/refs/tags/v2.0.6.tar.gz"
  sha256 "dd999558960f63daf36be8fe9fc04c32a15f53216115420c554b81cec6becb69"
  license "MIT"
  head "https://github.com/sammcj/gollama.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "053f69fd723843f58dee7426982df7d8ccbb718ff0b63b41a7f3a1e10e0566a6"
  end

  depends_on "go" => :build
  depends_on "ollama" => :test

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.Version=#{version}")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gollama -v")

    port = free_port
    ENV["OLLAMA_HOST"] = "localhost:#{port}"

    pid = spawn formula_opt_bin("ollama")/"ollama", "serve"
    begin
      sleep 3
      output = shell_output("#{bin}/gollama -h http://localhost:#{port} -s chatgpt")
      assert_match "No matching models found.", output
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
