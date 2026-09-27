class DbxCli < Formula
  desc "Command-line interface for DBX database connections, schema, and safe queries"
  homepage "https://dbxio.com"
  url "https://github.com/t8y2/dbx/archive/refs/tags/packages-v0.4.99.tar.gz"
  sha256 "8eb0ef0cbcc07709bbc3e926e91fcacfbd921bd2aca1f6cdb1c13003685f359d"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^packages-v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "ae73dfe0e74ecda415a3e69a7795ab99a1f9f4e8cb4ff0955657852b413931a6"
    sha256 cellar: :any, arm64_tahoe:       "4f2f9a585af8784b151d476553a5b564acc2951b8fc84d5b127b81c83982441f"
    sha256 cellar: :any, arm64_sequoia:     "c929dc34a82b9b7da8f15fb4f1db92051f821c0e9882a15a4a8989b47de8301e"
    sha256 cellar: :any, arm64_linux:       "325039623adff949c152db12e0b7d57b0179808b8a666c5c52cded82f0446f99"
    sha256 cellar: :any, x86_64_linux:      "2d86c1a536c6289e17752af4ed6f7f800b3554d173727eedc526cd5e38c26e96"
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
