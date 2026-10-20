class Wassette < Formula
  desc "Security-oriented runtime that runs WebAssembly Components via MCP"
  homepage "https://microsoft.github.io/wassette/"
  url "https://github.com/microsoft/wassette/archive/refs/tags/v0.8.1.tar.gz"
  sha256 "62a8b7197a3193c604fa4374619529e2ec95e1416017863625fe9b1449453c48"
  license "MIT"
  head "https://github.com/microsoft/wassette.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "612d09925a116301ce8d39f4d02998d81cd40bce4d1ab76479ac81a4924da1d2"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  deny_network_access!

  def crate_path = "crates/wassette-mcp-server"

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args, "--manifest-path", "#{crate_path}/Cargo.toml"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: crate_path)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/wassette --version")

    output = shell_output("#{bin}/wassette component list")
    assert_equal "0", JSON.parse(output)["total"].to_s
  end
end
