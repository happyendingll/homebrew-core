class Tombi < Formula
  desc "TOML formatter, linter and language server"
  homepage "https://github.com/tombi-toml/tombi"
  url "https://github.com/tombi-toml/tombi/archive/refs/tags/v1.9.3.tar.gz"
  sha256 "ed55954245177a23915a775830e0f1f5757e2337b88d7b873dd2dcf89d0bec4a"
  license "MIT"
  head "https://github.com/tombi-toml/tombi.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_releases
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0cdf0380df1342638b9597f3968ef4d3c8e7b73a330a2e86526a5570f2d63e7c"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "81b2ddfc77486b9facfef4dcc4c5ca33428ddeaab3c2443aba373963507f3691"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "cf209001ac9b8542558be12913c4f6275db31c87b60990b7135cbe9298da86e5"
    sha256 cellar: :any,                 arm64_linux:       "c746a78a0f1c2e16d64ffd1fa6d7b956603ec9ceaaabb8b3fff9500aaa884d4a"
    sha256 cellar: :any,                 x86_64_linux:      "78bebb9acfdc8207793f848974ffa2eb2685ef3721af673550d29bad1c3ed0a0"
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
