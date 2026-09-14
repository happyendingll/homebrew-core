class Weave < Formula
  desc "Entity-level semantic merge driver for Git using tree-sitter"
  homepage "https://ataraxy-labs.github.io/weave/"
  url "https://github.com/Ataraxy-Labs/weave/archive/refs/tags/v0.5.4.tar.gz"
  sha256 "e5a2da626bb329b7ad38cbd206dc9cf67e30be719e84900d45415d448da76af7"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/Ataraxy-Labs/weave.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "96f195e858b44e7aecc193a455ada85c6d24dd828eba8184551509e57b059746"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "libgit2"
  depends_on "openssl@3"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  conflicts_with "texlive", because: "both install a `weave` binary"

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/weave-cli")
    system "cargo", "install", *std_cargo_args(path: "crates/weave-driver")
    system "cargo", "install", *std_cargo_args(path: "crates/weave-mcp")
  end

  test do
    (testpath/"hello.py").write <<~PYTHON
      def greet():
          print("hello")

      def farewell():
          print("bye")
    PYTHON
    system "git", "init", testpath
    system "git", "-C", testpath, "add", "."
    system "git", "-C", testpath, "commit", "-m", "init"

    output = shell_output("#{bin}/weave setup 2>&1")
    assert_match "weave", output.downcase
  end
end
