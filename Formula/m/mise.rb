class Mise < Formula
  desc "Polyglot runtime manager (asdf rust clone)"
  homepage "https://mise.jdx.dev/"
  url "https://github.com/jdx/mise/archive/refs/tags/v2026.9.7.tar.gz"
  sha256 "91ab516c927c01fe317964e49986fff37379196001c46d7c9fd06c87e3a612cc"
  license "MIT"
  head "https://github.com/jdx/mise.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "3a183a936e4bba17c1c35b58df8bdb74ca48011180a6becaf22409ba25b17601"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a148acc542e44d96b3281bb0aadac4bf034eb934cc0162733d89f56b1980afb2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "82f737dffd9f006ea66460e7982fdf3a20d970812ad18fc50542a2f579705d89"
    sha256 cellar: :any,                 arm64_linux:       "de6d5185a355be0b4f25e69a416b199305f4e1a27b6a581b492fea88f3ed2151"
    sha256 cellar: :any,                 x86_64_linux:      "d92d4a855f51249a1d9348c43ef2f0af1a658e3bc8569d412de7742cbdaf8cf9"
  end

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "bzip2"

  on_linux do
    depends_on "openssl@3"
  end

  # downloads crates during install and binaries in the test
  deny_network_access! :postinstall

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@3")

    system "cargo", "install", *std_cargo_args
    man1.install "man/man1/mise.1"
    lib.mkpath
    touch lib/".disable-self-update"
    (share/"fish/vendor_conf.d/mise-activate.fish").write <<~FISH
      if [ "$MISE_FISH_AUTO_ACTIVATE" != "0" ]
        #{opt_bin}/mise activate fish | source
      end
    FISH

    # Untrusted config path problem, `generate_completions_from_executable` is not usable
    bash_completion.install "completions/mise.bash" => "mise"
    fish_completion.install "completions/mise.fish"
    zsh_completion.install "completions/_mise"
  end

  def caveats
    <<~EOS
      If you are using fish shell, mise will be activated for you automatically.
    EOS
  end

  test do
    system bin/"mise", "settings", "set", "experimental", "true"
    system bin/"mise", "use", "go@1.23"
    assert_match "1.23", shell_output("#{bin}/mise exec -- go version")
  end
end
