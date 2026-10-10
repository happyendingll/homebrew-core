class McpToolbox < Formula
  desc "MCP server for databases"
  homepage "https://github.com/googleapis/mcp-toolbox"
  url "https://github.com/googleapis/mcp-toolbox/archive/refs/tags/v1.14.0.tar.gz"
  sha256 "3dc8b7578b0549af3c7fb437cadb616d7fe9d56906692818edaac133fe6125ce"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "e941f8170534ba28e60bb6d6ed5242b166326c88fe34df32821099266cce6bc1"
  end

  depends_on "go" => :build

  conflicts_with "kahip", because: "both install `toolbox` binaries"

  # `test do` block binds a local port
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    ldflags = %W[-X github.com/googleapis/genai-toolbox/cmd.buildType=#{tap.user}]
    system "go", "build", *std_go_args(ldflags:, output: bin/"toolbox")
    generate_completions_from_executable(bin/"toolbox", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/toolbox --version")

    (testpath/"tools.yaml").write <<~YAML
      sources:
        my-sqlite-memory-db:
          kind: "sqlite"
          database: ":memory:"
    YAML

    port = free_port
    pid = spawn bin/"toolbox", "--tools-file", testpath/"tools.yaml", "--port", port.to_s

    begin
      sleep 5
      output = shell_output("curl -s -i http://localhost:#{port} 2>&1")
      assert_match "HTTP/1.1 200 OK", output, "Expected HTTP/1.1 200 OK response"
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
