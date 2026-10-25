class Maki < Formula
  desc "Efficient AI coding agent extendable by neovim-like Lua plugins"
  homepage "https://maki.sh"
  url "https://github.com/tontinton/maki/archive/refs/tags/v0.6.5.tar.gz"
  sha256 "4d2a3116625978fd82d9edf5f8309573c00564d138d6752f977245f8ea7d148b"
  license "MIT"
  head "https://github.com/tontinton/maki.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "55495dba7c45836d07d2db80bb37db5c0323001fe9954df80864d20f5983faf6"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["OPENSSL_NO_VENDOR"] = "1"
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/maki --version")

    (testpath/"test.rs").write <<~RUST
      fn greet(name: &str) -> String {
          format!("hi {name}")
      }
    RUST
    assert_match "greet(name: &str) -> String [1-3]", shell_output("#{bin}/maki index test.rs")
  end
end
