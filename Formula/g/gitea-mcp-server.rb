class GiteaMcpServer < Formula
  desc "Interactive with Gitea instances with MCP"
  homepage "https://gitea.com/gitea/gitea-mcp"
  url "https://gitea.com/gitea/gitea-mcp/archive/v1.7.0.tar.gz"
  sha256 "1ebf82dfc7ffafeadeec9bc8a28d628c86a440008f4f1b75678191bbeb074948"
  license "MIT"
  head "https://gitea.com/gitea/gitea-mcp.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "151ad7f3a5f45025489103cab5bda22d9dffc2bc710d00dfbd3302db44edcb08"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end

  test do
    json = <<~JSON
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26"}}
      {"jsonrpc":"2.0","id":2,"method":"tools/list"}
    JSON

    # Read the reply before closing stdin: 1.7.0 exits non-zero on EOF without flushing
    output = IO.popen("#{bin}/gitea-mcp-server stdio", "r+") do |io|
      io.write json
      io.readline
    end
    assert_match "Gitea MCP Server", output
  end
end
