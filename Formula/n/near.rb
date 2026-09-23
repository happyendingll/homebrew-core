class Near < Formula
  desc "Human-friendly console utility for interacting with NEAR Protocol"
  homepage "https://near.cli.rs"
  url "https://github.com/near/near-cli-rs/archive/refs/tags/v0.30.1.tar.gz"
  sha256 "57e1249856b70b3cf6562becc618602d3c1a1f3aca98e7d909f33dfdb85e5439"
  license any_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "c98a48f56ee77dc9bb23f47cbe0117bad6c0e30cfa56b34052d2bfa1a775a6b2"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@3"

  on_linux do
    depends_on "systemd"
    depends_on "zlib-ng-compat"
  end

  def install
    features = "ledger,ledger-ble,inspect_contract,verify_contract"
    system "cargo", "install", "--no-default-features", *std_cargo_args(features:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/near --version")
    connections = shell_output("#{bin}/near config show-connections 2>&1")
    assert_match "[network_connection.mainnet]", connections
    assert_match "[network_connection.testnet]", connections
  end
end
