class GitDelta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://dandavison.github.io/delta/"
  url "https://github.com/dandavison/delta/archive/refs/tags/0.20.0.tar.gz"
  sha256 "b1abf1dca07cc3dfee72484d2b0c1d1d97a27a0445fb8b2950c5c8e58c80b5e7"
  license "MIT"
  compatibility_version 1
  head "https://github.com/dandavison/delta.git", branch: "main"
  bottle do
    sha256 cellar: :any, arm64_golden_gate: "297b7deefa1d120d27bbcadcef8cd12b0755259f728223607e4da2cb22b95e58"
    sha256 cellar: :any, arm64_tahoe:       "0d7f73dc448e5a0cf470f0aebd531a89c2738021137345a04aa6445b071c93b1"
    sha256 cellar: :any, arm64_sequoia:     "e123fdbf4756e9e04c584057e8a5bdaa01a6d790d2c013a464aee47dcf9c2e0e"
    sha256 cellar: :any, arm64_linux:       "2a8b4986f44da31248039ab4da395e104802e1765453e27883160f632c432547"
    sha256 cellar: :any, x86_64_linux:      "27958ce773a0ad35bed07b322446aef836b8311d457482ff50aea0760a6b83fa"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "libgit2"
  depends_on "oniguruma"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["LIBGIT2_NO_VENDOR"] = "1"
    ENV["RUSTONIG_SYSTEM_LIBONIG"] = "1"

    system "cargo", "install", *std_cargo_args

    pkgshare.install "themes.gitconfig"

    generate_completions_from_executable(bin/"delta", "--generate-completion")
  end

  test do
    assert_match "delta #{version}", shell_output("#{bin}/delta --version")

    # Create a test repo
    system "git", "init"
    (testpath/"test.txt").write("Hello, Homebrew!")
    system "git", "add", "test.txt"
    system "git", "commit", "-m", "Initial commit"
    (testpath/"test.txt").append_lines("Hello, Delta!")
    system "git", "add", "test.txt"
    system "git", "commit", "-m", "Update test.txt"

    # Test delta with git log using pipe_output
    git_log_output = shell_output("git log -p --color=always")
    output = pipe_output(bin/"delta", git_log_output)
    assert_match "Hello, Delta!", output
  end
end
