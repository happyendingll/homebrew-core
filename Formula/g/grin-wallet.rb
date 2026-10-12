class GrinWallet < Formula
  desc "Official wallet for the cryptocurrency Grin"
  homepage "https://grin.mw"
  url "https://github.com/mimblewimble/grin-wallet/archive/refs/tags/v5.5.1.tar.gz"
  sha256 "a044c594c0492cc96b48e6f32080cfbd4e9154229647ed29f16ef5caed033208"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "4dfc50f6cb0476c32bfd938cf1a0e80f1b9200f098beed0d8fdf7bba48c13806"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "llvm" => :build

  on_linux do
    depends_on "openssl@4" # Uses Secure Transport on macOS
  end

  resource "grin" do
    url "https://github.com/mimblewimble/grin/archive/refs/tags/v5.5.2.tar.gz"
    sha256 "df68a9496db18f6f1e6e286a95ecdc5f3d25de38affe9872c650b4b004c1e2d3"
  end

  deny_network_access!

  def fetch
    resource("grin").stage buildpath/"grin"
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    system "yes | #{bin}/grin-wallet init"
    assert_path_exists testpath/".grin/main/wallet_data/wallet.seed"
  end
end
