class Shell2http < Formula
  desc "Executing shell commands via HTTP server"
  homepage "https://github.com/msoap/shell2http"
  url "https://github.com/msoap/shell2http/archive/refs/tags/v1.18.0.tar.gz"
  sha256 "0182c5d5a4574f7c932172001378132d99ed9b41432d159d70e3a19ef3c29145"
  license "MIT"
  head "https://github.com/msoap/shell2http.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "98c14e1a4c52a35b6d2b0dc9134eb9983915be9d20189517108c7467b845c5ed"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")

    man1.install "shell2http.1"
  end

  test do
    port = free_port
    pid = spawn bin/"shell2http", "-port", port.to_s, "/echo", "echo brewtest"
    sleep 1
    output = shell_output("curl -s http://localhost:#{port}")
    assert_match "Served by shell2http/#{version}", output

    output = shell_output("curl -s http://localhost:#{port}/echo")
    assert_match "brewtest", output
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
