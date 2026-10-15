class Opendetex < Formula
  desc "Tool to strip TeX or LaTeX commands from documents"
  homepage "https://github.com/pkubowicz/opendetex"
  url "https://github.com/pkubowicz/opendetex/releases/download/v2.8.12/opendetex-2.8.12.tar.bz2"
  sha256 "d1fcffe7290c6fff2db77e9074b896979b8ce72b3c2fc47de3341bb6652da02a"
  license "NCSA"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "5065abe845e9a76f75775e3c329a8465e2c6e7b538c082c22f82e35d969f4e7b"
  end

  uses_from_macos "flex" => :build

  conflicts_with "texlive", because: "both install `detex` binaries"

  deny_network_access!

  def install
    system "make"
    bin.install "detex"
    bin.install "delatex"
    man1.install "detex.1"
  end

  test do
    (testpath/"test.tex").write <<~'TEX'
      \documentclass{article}
      \begin{document}
      Simple \emph{text}.
      \end{document}
    TEX

    output = shell_output("#{bin}/detex test.tex")
    assert_equal "Simple text.\n", output
  end
end
