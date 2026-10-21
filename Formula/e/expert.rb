class Expert < Formula
  desc "Official Elixir Language Server Protocol implementation"
  homepage "https://expert-lsp.org"
  url "https://github.com/expert-lsp/expert/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "af65f7172e2ba54fe19064c8dea9c38619d50bd70a97961ae826a3c4d3bc378f"
  license "Apache-2.0"
  head "https://github.com/expert-lsp/expert.git", branch: "main"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "cd42560e7ca91b4ced24358eb8a9de6345035876192635d69d81bd9f07e1c26e"
    sha256 cellar: :any, arm64_tahoe:       "c8b621ee0fdb8bdd7837ccaa293ef717979aeb184d8c71d2ecc9f95f0e07f3d2"
    sha256 cellar: :any, arm64_sequoia:     "d245479eb5f4f576240d3e9afe4b2de2aaedf784bd684870b93dd8e035cca5b7"
    sha256 cellar: :any, arm64_linux:       "015f073279455a0fa84f88200ec5947c2bc44014c2bc9a249d1341ebd7a79c79"
    sha256 cellar: :any, x86_64_linux:      "250c631f836330bd19a4473a49faac3002be96a9533e0bd6af54d274d0940d52"
  end

  depends_on "elixir" => :build
  depends_on "erlang" => :build
  depends_on "just" => :build
  depends_on "openssl@4"

  uses_from_macos "ncurses"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "mix", "local.hex", "--force", "--if-missing"
    system "mix", "local.rebar", "--force", "--if-missing"

    system "just", "install", "--prefix=#{prefix}"
  end

  test do
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

    Open3.popen3(bin/"expert", "--stdio") do |stdin, stdout|
      stdin.write "Content-Length: #{json.size}\r\n\r\n#{json}"
      assert_match(/^Content-Length: \d+/i, stdout.readline)
    end
  end
end
