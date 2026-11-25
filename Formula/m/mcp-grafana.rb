class McpGrafana < Formula
  desc "MCP server for Grafana"
  homepage "https://github.com/grafana/mcp-grafana"
  url "https://github.com/grafana/mcp-grafana/archive/refs/tags/v2.4.0.tar.gz"
  sha256 "265b3541b97ec173c35bff992cab040aa4d1225279cb96dbb608dbc8182f6844"
  license "Apache-2.0"
  head "https://github.com/grafana/mcp-grafana.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "0f065cbbe8b971b1d8f4551758aa36971998c789f5c556bc81f065a1c1b412e9"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/mcp-grafana"
  end

  test do
    IO.popen([bin/"mcp-grafana", "--usage-stats=disabled"], "r+") do |pipe|
      Timeout.timeout(30) do
        pipe.puts JSON.generate(jsonrpc: "2.0", id: 1, method: "initialize", params: {
          protocolVersion: "2025-03-26", capabilities: {}, clientInfo: { name: "homebrew", version: "1.0" }
        })
        response = JSON.parse(pipe.readline)
        assert_equal 1, response.fetch("id")
        assert_match "This server provides access to your Grafana instance and the surrounding ecosystem",
                     response.fetch("result").fetch("instructions")

        pipe.puts JSON.generate(jsonrpc: "2.0", method: "notifications/initialized")
        pipe.puts JSON.generate(jsonrpc: "2.0", id: 2, method: "tools/list")
        response = JSON.parse(pipe.readline)
        assert_equal 2, response.fetch("id")
        tools = response.fetch("result").fetch("tools").map { |tool| tool.fetch("name") }
        assert_includes tools, "list_datasources"
        assert_includes tools, "query_prometheus"
      end
    end
  end
end
