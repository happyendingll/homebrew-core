class Neo4jMcp < Formula
  desc "Neo4j official Model Context Protocol server for AI tools"
  homepage "https://neo4j.com/docs/mcp/current/"
  url "https://github.com/neo4j/mcp/archive/refs/tags/v1.6.1.tar.gz"
  sha256 "08fcf97548428394e3262c52a0def70d317963ac81f6633816c409b8efd04387"
  license "GPL-3.0-or-later"
  head "https://github.com/neo4j/mcp.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "dd5878d6ea3ccf585ec4ad586607df06d293d2162da9a5f6ad4834c13f07f5eb"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.Version=v#{version}"), "./cmd/neo4j-mcp"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/neo4j-mcp --version")

    json = <<~JSON
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26"}}
      {"jsonrpc":"2.0","id":2,"method":"tools/list"}
    JSON

    output = pipe_output("#{bin}/neo4j-mcp 2>&1", json, 1)
    assert_match "Neo4j URI is required", output
  end
end
