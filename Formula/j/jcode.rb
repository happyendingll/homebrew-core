class Jcode < Formula
  desc "AI coding agent harness for the terminal"
  homepage "https://jcode.sh"
  url "https://github.com/1jehuang/jcode/archive/refs/tags/v0.89.1.tar.gz"
  sha256 "831116aefabcc45162f762bca91ce34e998f8e29c2d958f6c92268c789c7d79a"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0e20dc7e96c652708456b67301b5746f10e0c205b725f3e100c0b718f3decb3a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "e1dd3750796f6bc3c8c1dc5be7c0e2f22300fe8957df645e0f2a0e979766584c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "43b76be587ad3c8a4a9276cbc5e6de9d8af15d91eaa15438265012e44a0c77c5"
    sha256 cellar: :any,                 arm64_linux:       "b1b9f192273b625d11547ca0dd875caa56a20e198ca45a968bd73ebd984860c4"
    sha256 cellar: :any,                 x86_64_linux:      "30e0f54a3f82385cc37adcd70a7dc96f1809a74329063f603efb77863bc82ff1"
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
