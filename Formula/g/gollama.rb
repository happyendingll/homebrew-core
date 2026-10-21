class Gollama < Formula
  desc "Go manage your Ollama models"
  homepage "https://smcleod.net"
  url "https://github.com/sammcj/gollama/archive/refs/tags/v2.0.7.tar.gz"
  sha256 "7644ac3145809bc06a51e48cbf9c3512c92349e16161473e8953ff641d532bf8"
  license "MIT"
  head "https://github.com/sammcj/gollama.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "4fbefd49a01ae7666424991578aebd25a4f3aa30d62b98f83bb782c2bf007d93"
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
