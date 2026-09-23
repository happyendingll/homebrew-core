class Tinysearch < Formula
  desc "Tiny, full-text search engine for static websites built with Rust and Wasm"
  homepage "https://github.com/tinysearch/tinysearch"
  url "https://github.com/tinysearch/tinysearch/archive/refs/tags/v0.11.1.tar.gz"
  sha256 "6272d0f42bda3591be28bf465de4c9dda4ac6967b548a680f48379e5f0bb569b"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/tinysearch/tinysearch.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "e4d6fe46fd4ec234559834fd1b8b64506c78dbd968a856321ffc070e43319cda"
  end

  depends_on "rust" => :build
  depends_on "rustup" => :test
  depends_on "wasm-pack"

  def install
    system "cargo", "install", *std_cargo_args(features: "bin")
    pkgshare.install "fixtures"
  end

  test do
    ENV.prepend_path "PATH", formula_opt_bin("rustup")
    system "rustup", "set", "profile", "minimal"
    system "rustup", "default", "stable"
    system "rustup", "target", "add", "wasm32-unknown-unknown"

    system bin/"tinysearch", pkgshare/"fixtures/index.json"
    assert_path_exists testpath/"wasm_output/tinysearch_engine.wasm"
    assert_match "TinySearch WASM Demo", (testpath/"wasm_output/demo.html").read
  end
end
