class DockerLanguageServer < Formula
  desc "Language server for Dockerfiles, Compose files, and Bake files"
  homepage "https://www.docker.com"
  url "https://github.com/docker/docker-language-server/archive/refs/tags/v0.20.2.tar.gz"
  sha256 "f5dc558745a7a7324fd496a613f2ff3ada179f94499cbd3427d18f5c08d9d31f"
  license "Apache-2.0"
  head "https://github.com/docker/docker-language-server.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "c2747c284369f4900217f931addce871ccf14e1274bbb9ae4e3c5a4252a76af8"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = OS.mac? ? "1" : "0"

    ldflags = %W[-X github.com/docker/docker-language-server/internal/pkg/cli/metadata.Version=v#{version}]

    system "go", "build", *std_go_args(ldflags:), "./cmd/docker-language-server"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/docker-language-server --version")

    require "open3"

    json = <<~JSON
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "rootUri": null,
          "capabilities": {}
        }
      }
    JSON

    Open3.popen3("docker-language-server", "start", "--stdio") do |stdin, stdout|
      stdin.write "Content-Length: #{json.size}\r\n\r\n#{json}"
      assert_match(/^Content-Length: \d+/i, stdout.readline)
    end
  end
end
