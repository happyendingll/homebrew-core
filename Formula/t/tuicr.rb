class Tuicr < Formula
  desc "Code review TUI with vim keybindings"
  homepage "https://tuicr.dev/"
  url "https://github.com/agavra/tuicr/archive/refs/tags/v0.27.0.tar.gz"
  sha256 "420f72b7ffc6e40db50383719dbec162fa712130c7a7d83c21cd07d504dd59e7"
  license "MIT"
  head "https://github.com/agavra/tuicr.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "c0b6e5d9f1fba9843dfa8c1c87a4a93d7ed920853bf4c7e16db3514af1c1842a"
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
