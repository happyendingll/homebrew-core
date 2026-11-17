class SlintCompiler < Formula
  desc "Compiler for the Slint UI markup language"
  homepage "https://slint.dev/"
  url "https://github.com/slint-ui/slint/archive/refs/tags/v1.19.0.tar.gz"
  sha256 "9c15a9f6dfe94fbe96cb97dcb38207907403a67c9b23d8a93468ea1bb132246c"
  license "GPL-3.0-only"
  head "https://github.com/slint-ui/slint.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "b6265fb13a82e5acd88c0850785c606627a728a0a6009481303fc1d824da83d8"
  end

  depends_on "rust" => :build

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "fontconfig"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "tools/compiler")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/slint-compiler --version")

    (testpath/"test.slint").write <<~SLINT
      export component Test inherits Window {
        Text { text: "Hello, world"; }
      }
    SLINT

    system bin/"slint-compiler", "--format", "rust", "-o", testpath/"test.rs", testpath/"test.slint"
    assert_path_exists testpath/"test.rs"
  end
end
