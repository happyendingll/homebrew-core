class Aiken < Formula
  desc "Modern smart contract platform for Cardano"
  homepage "https://aiken-lang.org/"
  url "https://github.com/aiken-lang/aiken/archive/refs/tags/v1.1.24.tar.gz"
  sha256 "0508470ea01156ef7e275d97f12ceadc99d952897d4cb7454f790b15bfe31d0e"
  license "Apache-2.0"
  head "https://github.com/aiken-lang/aiken.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "e02f07c0a626e86f6b2b159b2a70893f506f5bccc066413e16b980986042c12b"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked", "--target", "host-tuple"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/aiken")

    generate_completions_from_executable(bin/"aiken", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aiken --version")

    system bin/"aiken", "new", "brewtest/hello"
    assert_path_exists testpath/"hello/README.md"
    assert_match "brewtest/hello", (testpath/"hello/aiken.toml").read
  end
end
