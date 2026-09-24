class Librefang < Formula
  desc "Self-hostable operating system for autonomous AI agents"
  homepage "https://librefang.ai"
  url "https://github.com/librefang/librefang/archive/refs/tags/v2026.9.14.tar.gz"
  sha256 "20bf429a30aeeb59b9412b5bc7e01ff35fd51e32803c6d8b4f9cdd53b8fe2049"
  license "MIT"
  head "https://github.com/librefang/librefang.git", branch: "main"

  bottle do
    rebuild 1
    sha256 cellar: :any, arm64_golden_gate: "53b2028f50eaa0e01c56499d7eea420feddd1d41e864acb8fec0ebd24c9d1847"
    sha256 cellar: :any, arm64_tahoe:       "86d706e7ce8834d5193b502d84d2559200e0759547b13fd466ce4d835ecb0897"
    sha256 cellar: :any, arm64_sequoia:     "f9f93221388e935911c4458a8336fe6c764133122845c46339c519e1080256ce"
    sha256 cellar: :any, arm64_linux:       "7e6def2219402dbed158f85601191db1f106f03d7704f775bca884608dcb75af"
    sha256 cellar: :any, x86_64_linux:      "fce7bdf6a4e0c08900dc853ee3d755f81c2c81894ba8561001213ba62c40cfe6"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  on_linux do
    depends_on "dbus"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/librefang-cli")
  end

  test do
    system bin/"librefang", "init", "--quick"
    assert_path_exists testpath/".librefang/config.toml"
  end
end
