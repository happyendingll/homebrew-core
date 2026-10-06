class Reposurgeon < Formula
  desc "Edit version-control repository history"
  homepage "http://www.catb.org/esr/reposurgeon/"
  url "https://gitlab.com/esr/reposurgeon/-/archive/5.12/reposurgeon-5.12.tar.gz"
  sha256 "e9a6cce233e8f01e2b30882b7d6cc7aefd0d6683ab51b92e6bac582be36a8859"
  license "BSD-2-Clause"
  head "https://gitlab.com/esr/reposurgeon.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "f525488d7ffd58a2306fae4830066092b029979efa934166bf212f87825ffaca"
  end

  depends_on "asciidoctor" => :build
  depends_on "go" => :build
  depends_on "ruby" => :build # same Ruby as asciidoctor

  on_linux do
    depends_on "gawk" => :build
  end

  def install
    ENV.append_path "GEM_PATH", formula_opt_libexec("asciidoctor")
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
    elisp.install "reposurgeon-mode.el"
  end

  test do
    system "git", "init"
    system "git", "commit", "--allow-empty", "--message", "brewing"

    assert_match "brewing",
      shell_output("#{bin}/reposurgeon read list")
  end
end
