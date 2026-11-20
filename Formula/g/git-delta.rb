class GitDelta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://dandavison.github.io/delta/"
  url "https://github.com/dandavison/delta/archive/refs/tags/0.21.2.tar.gz"
  sha256 "d8b5b3c3a5a354b5fddd6e7156f62c8a5db2a33aad9d49debd536777facb66b7"
  license "MIT"
  compatibility_version 1
  head "https://github.com/dandavison/delta.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "a2107a16e24353992282b1b2dc9692234932d7de30fff9f6c6a1c928f9d19d63"
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
