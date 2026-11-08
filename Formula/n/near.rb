class Near < Formula
  desc "Human-friendly console utility for interacting with NEAR Protocol"
  homepage "https://near.cli.rs"
  url "https://github.com/near/near-cli-rs/archive/refs/tags/v0.31.1.tar.gz"
  sha256 "f21d6cfb7261548915e226aec99d04e8ee810a6f831ca6b37c90e22baf02016c"
  license any_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "934941227e9b4fe9eb5ed1865e1dd9188eac9bc95b928ce8201475e02ef90f1a"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  on_linux do
    depends_on "systemd"
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
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
