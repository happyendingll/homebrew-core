class Pixtuoid < Formula
  desc "Terminal pixel-art office for AI coding agents"
  homepage "https://github.com/IvanWng97/pixtuoid"
  url "https://github.com/IvanWng97/pixtuoid/archive/refs/tags/v0.21.0.tar.gz"
  sha256 "ca7237be6ab3310b3c8ca6de2cdd6a03968144a201c9c254974ee2bda8c37329"
  license "MIT"
  head "https://github.com/IvanWng97/pixtuoid.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "8226af1eac9eac25b705fbdad1f7eb79767116014b85d604d9b2153cff88fd8c"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "alsa-lib"
  end

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", "--locked", "--target", "host-tuple"
  end

  def install
    # Drop upstream's x86_64 Linux lld linker pin
    rm ".cargo/config.toml"

    system "cargo", "install", *std_cargo_args(path: "crates/pixtuoid")
    system "cargo", "install", *std_cargo_args(path: "crates/pixtuoid-hook")

    (man1/"pixtuoid.1").write Utils.safe_popen_read(bin/"pixtuoid", "man")
    generate_completions_from_executable(bin/"pixtuoid", "completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pixtuoid --version")

    connected = JSON.parse(shell_output("#{bin}/pixtuoid connect claude-code --json", 1)).first
    assert_equal "claude-code", connected["id"]
    assert_equal "failed", connected["outcome"]
  end
end
