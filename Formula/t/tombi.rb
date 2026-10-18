class Tombi < Formula
  desc "TOML formatter, linter and language server"
  homepage "https://github.com/tombi-toml/tombi"
  url "https://github.com/tombi-toml/tombi/archive/refs/tags/v1.8.7.tar.gz"
  sha256 "46b69979e5edacbee5c656f802dc47abbabc2450a47e7c947b06daa5358f4053"
  license "MIT"
  head "https://github.com/tombi-toml/tombi.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_releases
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c8df8300bcefc9d699c5fd3b4321f0c38f0b8a3c2944d7bdf27630028d4f4fd8"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "74b1bab5ceeb999d70fbf922401fb6c15935242643ab3f46f7ec7b32a256eee5"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "2ad88a447f7e73893418a6d180c1516d6d1196b034ade5863c2c56c6bfe084de"
    sha256 cellar: :any,                 arm64_linux:       "82a615347949fd7734fcfe42c6f2c84b7a9f0d84a55532e1789e312f0747e6ae"
    sha256 cellar: :any,                 x86_64_linux:      "3986e85546f6fd3f22ad62bb0498b53b6e8b87c3b63824c6411b4787f2932b8e"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args, "--manifest-path", "rust/tombi-cli/Cargo.toml"
  end

  def install
    ENV["TOMBI_VERSION"] = version.to_s
    system "cargo", "xtask", "set-version"
    system "cargo", "install", *std_cargo_args(path: "rust/tombi-cli")

    generate_completions_from_executable(bin/"tombi", "completion", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tombi --version")

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

    Open3.popen3(bin/"tombi", "lsp") do |stdin, stdout|
      stdin.write "Content-Length: #{json.size}\r\n\r\n#{json}"
      sleep 1
      assert_match(/^Content-Length: \d+/i, stdout.readline)
    end
  end
end
