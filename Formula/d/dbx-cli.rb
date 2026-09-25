class DbxCli < Formula
  desc "Command-line interface for DBX database connections, schema, and safe queries"
  homepage "https://dbxio.com"
  url "https://github.com/t8y2/dbx/archive/refs/tags/packages-v0.4.97.tar.gz"
  sha256 "0daa159efa03b689796cb7fe906ed54f025a7a5d32b69f3bede150f511fcff33"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^packages-v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "2b2b4e5ac1c0b133db267531a99ccbe9295d679e03436834d1df2fd367cf95c4"
    sha256 cellar: :any, arm64_tahoe:       "1b9fa3e6c9ffcfacb7aebfdfb53829a46eec7ee8ca4628c2b8de3a5d3072a48b"
    sha256 cellar: :any, arm64_sequoia:     "a6c8c54a844f3e535e1892557c89a0ca7df36b551b38d7225cffb03bf233f963"
    sha256 cellar: :any, arm64_linux:       "ffbbed45e7077e73a2381c2ece487bf0d40c9782e14e78f12866e6d2d7a052c3"
    sha256 cellar: :any, x86_64_linux:      "7f6470ef95d33eb6dc1f5297863d3175d4898ba56304049009daf0ef148bc26a"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  on_linux do
    depends_on "fontconfig"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/dbx-cli")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dbx --version")

    output = shell_output("#{bin}/dbx capabilities --json")
    capabilities = JSON.parse(output)
    assert capabilities.key?("directQueryTypes"), "Missing directQueryTypes"
    assert capabilities.key?("bridgeRequiredTypes"), "Missing bridgeRequiredTypes"
    assert capabilities["directQueryTypes"].is_a?(Array), "directQueryTypes should be an array"
  end
end
