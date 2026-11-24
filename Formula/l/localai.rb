class Localai < Formula
  desc "OpenAI alternative"
  homepage "https://localai.io"
  url "https://github.com/mudler/LocalAI/releases/download/v5.0.1/LocalAI-v5.0.1-source.tar.gz"
  sha256 "d2ca736513a89a56761e5ba5d1c9659db177ad605855cb3b66a94b61d5a559f7"
  license "MIT"
  head "https://github.com/mudler/LocalAI.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "e827bcc8a0e7ff47e50ef2db426280858db5fa389763ae769aeb9cd8e9be78ce"
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

    # The add-on owner opens `/` at startup, which the Linux test sandbox denies
    with_test_process(bin/"local-ai", "run", "--address", addr, "--addons-enabled=false") do
      sleep 5

      response = shell_output("curl -s -i #{addr}/readyz")
      assert_match "HTTP/1.1 200 OK", response
    end
  end
end
