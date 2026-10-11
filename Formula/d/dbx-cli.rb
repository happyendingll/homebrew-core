class DbxCli < Formula
  desc "Command-line interface for DBX database connections, schema, and safe queries"
  homepage "https://dbxio.com"
  url "https://github.com/t8y2/dbx/archive/refs/tags/packages-v0.4.115.tar.gz"
  sha256 "32f213f2b0a9bea290712fea5daa81af778b611bfbcb49e28d85862a250d1c65"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^packages-v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "fef0e163aa9ac47b24acced0bfe2a6ffc9406941a6fe67955ae537a184884309"
    sha256 cellar: :any, arm64_tahoe:       "be5eceb1ef4b120d5c559c6abf806b6123d6785cd1c4521ced87430cc00dbd6e"
    sha256 cellar: :any, arm64_sequoia:     "7882f0c90c3633b43ff7306c0238d2fbcf58c9d333a8bd0ceec512c720b2f80d"
    sha256 cellar: :any, arm64_linux:       "e730744bef741338c3529ca4c48ed3a3bee22407b03ef3961ceb66f100ad42ac"
    sha256 cellar: :any, x86_64_linux:      "7c0e5bf86bac71570f96f1416aa0a3ddcbc1978f9cb176c63c78ed8fc8a8b25e"
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
