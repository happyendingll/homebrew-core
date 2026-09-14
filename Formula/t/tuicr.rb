class Tuicr < Formula
  desc "Code review TUI with vim keybindings"
  homepage "https://tuicr.dev/"
  url "https://github.com/agavra/tuicr/archive/refs/tags/v0.25.0.tar.gz"
  sha256 "e7553c629d89c3fae2845a21bddf365cc542e0d2f2eed01e2fb5ad7017bd81fc"
  license "MIT"
  head "https://github.com/agavra/tuicr.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "f03324a2da227f7e2422662828ac6d56d58b3de5dacf576e8a08540eb5e3f0aa"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "libgit2"

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    system "git", "init"
    system "git", "config", "user.name", "test"
    system "git", "config", "user.email", "test@example.com"
    (testpath/"test.txt").write("hello world\n")
    system "git", "add", "test.txt"
    system "git", "commit", "-m", "Initial commit"

    assert_equal "[]\n", shell_output("#{bin}/tuicr review list --all")
  end
end
