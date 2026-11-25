class SlintCompiler < Formula
  desc "Compiler for the Slint UI markup language"
  homepage "https://slint.dev/"
  url "https://github.com/slint-ui/slint/archive/refs/tags/v1.19.1.tar.gz"
  sha256 "9c921f375de12fcf8647ddf076cf13af579b5cff61db5800e378cbedea9bff19"
  license "GPL-3.0-only"
  head "https://github.com/slint-ui/slint.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "ce3216c686b5571078625256459cae619f132ffebd9edd450bb3ae35aeea6f73"
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
