class Himalaya < Formula
  desc "CLI email client written in Rust"
  homepage "https://pimalaya.org"
  url "https://github.com/pimalaya/himalaya/archive/refs/tags/v3.0.0.tar.gz"
  sha256 "e6843e062be203d6c97b392f4f4f58844c3ae16f42849704727029e882274e0a"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "67716d2bf67f254b67a4944d4e92fc1896eac1023c9c127db4e383078c61ff21"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    system bin/"himalaya", "manual", "--dir", buildpath
    man1.install Dir["*.1"]
    generate_completions_from_executable(bin/"himalaya", "completion")
  end

  test do
    (testpath/"config.toml").write <<~TOML
      [accounts.personal]
      default = true
      email = "alice@example.org"
      maildir.root = "#{testpath}/Mail"
    TOML

    assert_match "personal", shell_output("#{bin}/himalaya --config config.toml account list")
  end
end
