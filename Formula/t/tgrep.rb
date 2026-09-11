class Tgrep < Formula
  desc "Trigram-indexed grep for fast regex search in large codebases"
  homepage "https://github.com/microsoft/tgrep"
  url "https://github.com/microsoft/tgrep/archive/refs/tags/v1.0.7.tar.gz"
  sha256 "741e36d717298d093efa71bdd3e429f7af7a1c5ba9e8a8e0993b990398602cf8"
  license "MIT"
  head "https://github.com/microsoft/tgrep.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c662b7ca3318233a21b193cc93e050587b309eb3e8daa237e8fcf43bf6d68a18"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "7016f11a8a1b32a23488bbb549d9d41a95306f3a60413c1f4828b7af385f8a4f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "23cd172022bd8512674ef91e612a2ec2619ab3c6a4d8ec9cf3fbab62c4b4bced"
    sha256 cellar: :any,                 arm64_linux:       "3fd91b9fc2a80512e17a461e2d74ac02fa792051aace90e145e221fe074d849e"
    sha256 cellar: :any,                 x86_64_linux:      "ac5b07e1e77eed15765e93ce99bd8687f9d63c9d7d5ee94897932b92647a9440"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "tgrep-cli")
  end

  test do
    (testpath/"src").mkpath
    (testpath/"src/main.rs").write <<~RUST
      fn main() {
          println!("hello trigram");
      }
    RUST
    (testpath/"src/lib.rs").write <<~RUST
      pub fn helper() -> u32 { 42 }
    RUST
    (testpath/"notes.txt").write "nothing to see here\n"

    system bin/"tgrep", "index", testpath

    matches = shell_output("#{bin}/tgrep 'hello trigram' #{testpath}")
    assert_match "src/main.rs", matches
    assert_match "hello trigram", matches

    assert_match version.to_s, shell_output("#{bin}/tgrep --version")
  end
end
