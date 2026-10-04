class DbxCli < Formula
  desc "Command-line interface for DBX database connections, schema, and safe queries"
  homepage "https://dbxio.com"
  url "https://github.com/t8y2/dbx/archive/refs/tags/packages-v0.4.106.tar.gz"
  sha256 "353009f50b0f9895b58219ee067edf2e602bdddf286e6bd64c7fcde1ffdf54b8"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^packages-v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "38df404683ec5e3870478e7b055e1fb0dbadfa3c7f816242b7a43daa8c486e52"
    sha256 cellar: :any, arm64_tahoe:       "fa40b9f06c2e52144f781ba526103db6b1f195c64da7bafb2245fe01efc8afc1"
    sha256 cellar: :any, arm64_sequoia:     "7ad682b26ca550d1715cb2a40131159d6c2d0d113596c0bb40947ca683747e71"
    sha256 cellar: :any, arm64_linux:       "72a03f46a60696c6eac6c20a6449fdc5d9037e0ad6cce3ac40a01fe4fdd299ee"
    sha256 cellar: :any, x86_64_linux:      "bfe296bae11ee1a986c5f1bd709c24a9a7ccf246899bfd53f4d844caa5538cc0"
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
