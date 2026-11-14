class AnycableGo < Formula
  desc "WebSocket server with action cable protocol"
  homepage "https://anycable.io"
  url "https://github.com/anycable/anycable/archive/refs/tags/v1.6.21.tar.gz"
  sha256 "af9cc9a79e758e4ee125bd6d74850fa747817da205c69fe0ecfe999fe06a336a"
  license "MIT"
  head "https://github.com/anycable/anycable.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "4b33fee0b379ead6fcdfea262472c78a67e0b51558f65afec57af30ec93f8bae"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = if build.head?
      "-X github.com/anycable/anycable/utils.sha=#{version.commit}"
    else
      "-X github.com/anycable/anycable/utils.version=#{version}"
    end

    system "go", "build", *std_go_args(ldflags:), "./cmd/anycable-go"
  end

  test do
    port = free_port
    pid = spawn bin/"anycable-go", "--port=#{port}"
    sleep 1
    output = shell_output("curl -sI http://localhost:#{port}/health")
    assert_match(/200 OK/m, output)
  ensure
    Process.kill("HUP", pid)
  end
end
