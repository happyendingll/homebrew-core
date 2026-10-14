class Jcode < Formula
  desc "AI coding agent harness for the terminal"
  homepage "https://jcode.sh"
  url "https://github.com/1jehuang/jcode/archive/refs/tags/v0.96.0.tar.gz"
  sha256 "02968e2235660a1befe377835d6910e9002a0d45dc7ed9112cb889efbe2196a0"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "1afb8b5612132056f2900a78c7a6a5f316bea51b568bf9f5a14a9eb496a4ebc9"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "b213486911153043bfed51e17e4814011b111708c357bc7451ed09f944cc683a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "99ec3204fabe366faf12a133505dfcb9031ef95008841690dc39d8bc639857ef"
    sha256 cellar: :any,                 arm64_linux:       "8bca95b4640da35be890d7d7913510ffef97b2076a49591e4e0ee614ad5fe58a"
    sha256 cellar: :any,                 x86_64_linux:      "db45c8d81ee9f8c6f610c7837e7ee05ed7a920b8b60548e253cfb13445c5d96d"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  deny_network_access! :build

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # Disable background auto-update by default
    inreplace "src/cli/args.rs",
              '#[arg(long, global = true, default_value = "true")]',
              '#[arg(long, global = true, default_value = "false")]'

    # Redirect `jcode update` to Homebrew
    inreplace "src/cli/dispatch.rs",
              "hot_exec::run_update()?;",
              'eprintln!("Please update jcode using: brew upgrade jcode");'

    system "cargo", "install", *std_cargo_args
    rm bin/"test_api"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jcode --version")
    assert_match "Please update jcode using: brew upgrade jcode", shell_output("#{bin}/jcode update 2>&1")

    system bin/"jcode-harness", "--cwd", testpath
    assert_match "alpha2", (testpath/"sample.txt").read
  end
end
