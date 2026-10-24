class GoCamo < Formula
  desc "Secure image proxy server"
  homepage "https://github.com/cactus/go-camo"
  url "https://github.com/cactus/go-camo/archive/refs/tags/v3.1.tar.gz"
  sha256 "255081875bd70918a8f9a72ab6ea06a047cf5fb2eef8618c5c12a259787616bf"
  license "MIT"
  head "https://github.com/cactus/go-camo.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "6cc0e36baa0011028d1ac09185a20a6c54687a4fcb9e58599beacd091febc3db"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X main.ServerVersion=#{version}"
    tags = "netgo,production"
    system "go", "build", *std_go_args(ldflags:, tags:), "./cmd/go-camo"
    system "go", "build", *std_go_args(ldflags:, tags:, output: bin/"url-tool"), "./cmd/url-tool"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/go-camo --version")
    assert_match version.to_s, shell_output("#{bin}/url-tool --version")

    port = free_port
    spawn bin/"go-camo", "--key", "somekey", "--listen", "127.0.0.1:#{port}", "--metrics"
    sleep 1
    assert_match "200 OK", shell_output("curl -sI http://localhost:#{port}/metrics")

    url = "https://golang.org/doc/gopher/frontpage.png"
    encoded = shell_output("#{bin}/url-tool -k 'test' encode -p 'https://img.example.org' '#{url}'").chomp
    decoded = shell_output("#{bin}/url-tool -k 'test' decode '#{encoded}'").chomp
    assert_equal url, decoded
  end
end
