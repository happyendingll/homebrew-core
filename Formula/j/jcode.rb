class Jcode < Formula
  desc "AI coding agent harness for the terminal"
  homepage "https://jcode.sh"
  url "https://github.com/1jehuang/jcode/archive/refs/tags/v0.88.0.tar.gz"
  sha256 "967e5a825f29b1ed3ab9649fe55966545ba4eba8e0d44e2897b015d2ada43b96"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "f581c5a1691d1a8c4d156a4ed915b42a52523486043867e69648dd72488c8d34"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "ff0fe3b9c3d36ed45070c292c1b449f0f299ce8b8ae350ea422316d89b6a22d9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "d44e611bbf057fa5921182515c6228c687f5d934c5de66bda5acd7ade8fad23a"
    sha256 cellar: :any,                 arm64_linux:       "e234f8a75da512865a4c4a2eeb02ca65cfd71f3c1eedffeb2c1789b373daa408"
    sha256 cellar: :any,                 x86_64_linux:      "8cae620a8b6fbcbe066590372b8f2318583b3da71fcf738a846391516ca43f7e"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@3"
  end

  deny_network_access! :build

  def fetch
    system "cargo", "fetch", "--locked"
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
