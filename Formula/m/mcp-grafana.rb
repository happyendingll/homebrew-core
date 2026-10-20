class McpGrafana < Formula
  desc "MCP server for Grafana"
  homepage "https://github.com/grafana/mcp-grafana"
  url "https://github.com/grafana/mcp-grafana/archive/refs/tags/v2.1.0.tar.gz"
  sha256 "4755ebd3ac58cc21f3e239ba1684058ca0f023ddfa1827dc99817b550034f487"
  license "Apache-2.0"
  head "https://github.com/grafana/mcp-grafana.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "a81bf395f1166922c3ae1613e2fa7c6b173f64028d11f6deff9c5674b0c38bf5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "21ff97ea71dfa94254f9d79df04323340b7c6574b77f61955e902070598b4353"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c62afe3b46fb5843216d248cc714bed32cbfb125b1d06f17d849fa4779a2a7b5"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "b36cc94fa486aefa8d26f2b0fec4e062384dc1697a6fac1056a883dee8ca553f"
    sha256 cellar: :any,                 x86_64_linux:      "9c0edf5f00934b9a250a8343dda7ef1bc74eb4c5df11ffadf32fbe0ab146dc5b"
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
