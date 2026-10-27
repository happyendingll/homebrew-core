class DbxCli < Formula
  desc "Command-line interface for DBX database connections, schema, and safe queries"
  homepage "https://dbxio.com"
  url "https://github.com/t8y2/dbx/archive/refs/tags/packages-v0.4.133.tar.gz"
  sha256 "9504b63e1a026f67cbfa7c90b9ac3227e74fe7844ccab0f4c0296e03b769b558"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^packages-v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "c60a4383c7c9a6eecce3d83d436122adc92fbe7fe386555389aaf135b3d6ed1d"
    sha256 cellar: :any, arm64_tahoe:       "4c38c5f43f9ca703621fea9650c1e0e34d4a0161e8aa4985f7b4efc04b178640"
    sha256 cellar: :any, arm64_sequoia:     "f90bd3af5a500040044d4071870f175dffc733dd9b603e0c47f4b4547498cd67"
    sha256 cellar: :any, arm64_linux:       "b916c8119f1f97497d2c5e9aa79fa286736f548b13f80b50fead72d0a66916ac"
    sha256 cellar: :any, x86_64_linux:      "729b01868f63f34b81f599c937e7967b5905941748b061941ffb5da7e5f26fc9"
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
