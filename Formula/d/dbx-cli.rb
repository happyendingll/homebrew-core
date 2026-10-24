class DbxCli < Formula
  desc "Command-line interface for DBX database connections, schema, and safe queries"
  homepage "https://dbxio.com"
  url "https://github.com/t8y2/dbx/archive/refs/tags/packages-v0.4.129.tar.gz"
  sha256 "81c26a5db57b5871055da3788aa21ca5f2263ee23a4d38495b0e7854c21c48c7"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^packages-v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "1f7019d270494852bd4bcbebed0c7518f54dbfe74a98fd15c6894820bf0b7247"
    sha256 cellar: :any, arm64_tahoe:       "24f46b162454adffdfc6c240a0381f1f67c71042f4b5a3f77d1722d5f2eef80d"
    sha256 cellar: :any, arm64_sequoia:     "ae319c895bfc16452a3f769fc39cb5e37d237f34f429b1333e8664b4693346f7"
    sha256 cellar: :any, arm64_linux:       "a4a83db29a21bdfac065ea1312494b1494d1df042c46b6e59743f70df78923da"
    sha256 cellar: :any, x86_64_linux:      "412ffaa9c837556099f69cb86bbd05b4b8ee0c70233abc71beab2f74cf2bc447"
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
