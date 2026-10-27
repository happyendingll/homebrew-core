class Tuicr < Formula
  desc "Code review TUI with vim keybindings"
  homepage "https://tuicr.dev/"
  url "https://github.com/agavra/tuicr/archive/refs/tags/v0.28.0.tar.gz"
  sha256 "f8b877dae2bb7af49f807698c14d55451856fc2099ff011b97aa53977bb4e22a"
  license "MIT"
  head "https://github.com/agavra/tuicr.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "14751ba803f5e68851f8857a50e61f554f5e9be5868609f8fff4579bae652496"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "libgit2"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

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
