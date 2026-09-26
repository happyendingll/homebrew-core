class GrinWallet < Formula
  desc "Official wallet for the cryptocurrency Grin"
  homepage "https://grin.mw"
  url "https://github.com/mimblewimble/grin-wallet/archive/refs/tags/v5.5.0.tar.gz"
  sha256 "faa8deebb693cd43d62f4c4c5c598294f7a136929d8dcea1c187656342cae01d"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "32ee501fd41e4b8bd49991a562bda0675418408027bf3711541c2d43c2792927"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "llvm" => :build

  on_linux do
    depends_on "openssl@4" # Uses Secure Transport on macOS
  end

  resource "grin" do
    url "https://github.com/mimblewimble/grin/archive/refs/tags/v5.5.1.tar.gz"
    sha256 "841a698986ff05768c6d7cdf2e59d44571533522fbcffdab0a0de01c8de1d4a3"
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
