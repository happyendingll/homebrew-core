class McpToolbox < Formula
  desc "MCP server for databases"
  homepage "https://github.com/googleapis/mcp-toolbox"
  url "https://github.com/googleapis/mcp-toolbox/archive/refs/tags/v1.13.0.tar.gz"
  sha256 "f341a28e9751cc4822431b400eaa1d4f85557afd6f66449a2bab8f6252b2688e"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "28b1903887447ed9a6187213cd43abbda985015398abd0b8dc0a38b21f6f3848"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "0464629d7d213dd72869ae527560bbc390f2d96b6a9b7ebe29f3dac9bfc4e92d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "d89de1d5a24f3e2bd595c9cb2b737d54e858d6414e33ca99eaf4a626c9a56d27"
    sha256 cellar: :any,                 arm64_linux:       "782c13cc431823aef505e200f307496f1a9ade7ec95153bea5b4108105d34507"
    sha256 cellar: :any,                 x86_64_linux:      "df569ec614124b72108482a899e6c2d743e4de4001d063bc98f93a17b5dd82f2"
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
