class DbxCli < Formula
  desc "Command-line interface for DBX database connections, schema, and safe queries"
  homepage "https://dbxio.com"
  url "https://github.com/t8y2/dbx/archive/refs/tags/packages-v0.4.102.tar.gz"
  sha256 "7aef027388ebf5a2fab0cab978735b4a53ba48c391e1d580a50334d52d5a2e24"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^packages-v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "570ae7c5b74de779879ab8154315a5ccc3080c41fcba741f9bc4a906ff9c505f"
    sha256 cellar: :any, arm64_tahoe:       "c86ab68957137a2b2748f54df15239ea8b2b5b00b42071cc36e15e91457a7065"
    sha256 cellar: :any, arm64_sequoia:     "eec3c6c291badd2cfad6c69ba79378212f2c7a6caf49d70bdb2ff5e9bed15495"
    sha256 cellar: :any, arm64_linux:       "bbe598dfcf4c27f186d11673ddde2967bdc2d6d606b5ada51593e7965aebec1b"
    sha256 cellar: :any, x86_64_linux:      "32e6a0a5859bb95f2e6b7a8e20900f17dd1f2ce6caeb6615e580a19da5eef8f7"
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
