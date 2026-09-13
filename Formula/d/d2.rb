class D2 < Formula
  desc "Modern diagram scripting language that turns text to diagrams"
  homepage "https://d2lang.com/"
  url "https://github.com/d2lang/d2/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "1256ad3907bceb4fcee7ed40d17c5726f8b602eea900e94500ba3352e96febbc"
  license "MPL-2.0"
  head "https://github.com/d2lang/d2.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "b27f906acc2bc2dcb7b68df7fd32a7b96518ef0af0df89bc46f61f412ebb35e9"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/d2lang/d2/lib/version.Version=v#{version}"
    system "go", "build", *std_go_args(ldflags:)
    man1.install "ci/release/template/man/d2.1"
  end

  test do
    test_file = testpath/"test.d2"
    test_file.write <<~EOS
      homebrew-core -> brew: depends
    EOS

    system bin/"d2", "test.d2"
    assert_path_exists testpath/"test.svg"

    assert_match "dagre is a directed graph layout algorithm implemented natively in Go by Dagro",
      shell_output("#{bin}/d2 layout dagre")

    assert_match version.to_s, shell_output("#{bin}/d2 version")
  end
end
