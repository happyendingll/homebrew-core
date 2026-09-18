class Localai < Formula
  desc "OpenAI alternative"
  homepage "https://localai.io"
  url "https://github.com/mudler/LocalAI/releases/download/v4.10.0/LocalAI-v4.10.0-source.tar.gz"
  sha256 "5589402839753647e3ae666b724e97f3951c4863587dff47bc56efdbd5500f91"
  license "MIT"
  head "https://github.com/mudler/LocalAI.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "ed7138944ff8b156b19bbb6780218c417762f346f8aa00c1145d4c36119ab0a3"
  end

  depends_on "go" => :build
  depends_on "node" => :build
  depends_on "protobuf" => :build
  depends_on "protoc-gen-go" => :build
  depends_on "protoc-gen-go-grpc" => :build

  def install
    ENV["SDKROOT"] = MacOS.sdk_path if OS.mac?

    system "make", "build", "VERSION=#{version}"
    bin.install "local-ai"
  end

  test do
    addr = "127.0.0.1:#{free_port}"

    pid = spawn bin/"local-ai", "run", "--address", addr
    sleep 5

    begin
      response = shell_output("curl -s -i #{addr}/readyz")
      assert_match "HTTP/1.1 200 OK", response
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
