class DbxCli < Formula
  desc "Command-line interface for DBX database connections, schema, and safe queries"
  homepage "https://dbxio.com"
  url "https://github.com/t8y2/dbx/archive/refs/tags/packages-v0.4.124.tar.gz"
  sha256 "64912085ceb44f2b876fafa08a5806904724ae37c25bc05ba1f953adefeb1075"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^packages-v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "c939a347fc3c8ecee845d1f7bf58db722914d482469e30f041e2d2926de32ddc"
    sha256 cellar: :any, arm64_tahoe:       "89e0749fe01fb9ddb17d5cd647e1f1f3e4b7fcb83a0ee8285ef8c54684af512b"
    sha256 cellar: :any, arm64_sequoia:     "ad694677ce1a3ab28020465c34d45584cf23f770a6de932055eed39bd93aa41b"
    sha256 cellar: :any, arm64_linux:       "6b3e530a08dbb9021b1c5cb2051e96bf7f82ef72be16a99b0abb1ce49510024b"
    sha256 cellar: :any, x86_64_linux:      "32a1fc4f375b3ff549449e32a632a1cddbfca74159542f340846042e287fd80a"
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
