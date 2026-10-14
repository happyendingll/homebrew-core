class Jcode < Formula
  desc "AI coding agent harness for the terminal"
  homepage "https://jcode.sh"
  url "https://github.com/1jehuang/jcode/archive/refs/tags/v0.97.0.tar.gz"
  sha256 "fc3ed4abac463574c23426728455213284f437c33512fff49701b0b85daca214"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "d491910f26f059dd645cdbbbcc48655b836209e9b5c1d22e51f31b293a9aa6f0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4dff6b6c1d87e1e2f4b1c12523bc82c15fa44378059a09fd8a1b2bffa63274c1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "4c407df9fdb145adda54050c4fa1f2bbe71ec46a1dfa5bea8061dd732f7a254c"
    sha256 cellar: :any,                 arm64_linux:       "f1f1cc687616e3e07f880d7b4b3b3bc5f8a188abb61fc8a949ccdf48cdfb2d19"
    sha256 cellar: :any,                 x86_64_linux:      "597172cfeae835663c37d7e8cd5c05610bd1e3bb7a796f2cd7a3df4c97e009f5"
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
