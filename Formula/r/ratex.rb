class Ratex < Formula
  desc "Fast TeX engine written in Rust"
  homepage "https://github.com/leoliu0/ratex"
  url "https://github.com/leoliu0/ratex/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "469fb82b5aeb24cba427eee292315141565aab40178353a2b0802fb40c25504d"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/leoliu0/ratex.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "747fb590252763c4ac29fa70d8cc786d148e292b9413acc00a1301f76ff62f98"
  end

  depends_on "rust" => :build

  conflicts_with "texlive", because: "both install `lualatex`, `pdflatex`, `xelatex` binaries"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # TODO: Remove these settings once a release includes upstream's embedded-archive memory fix.
    # https://github.com/leoliu0/ratex/issues/16
    ENV.deparallelize
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "false"
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"

    # Every bin embeds the package archive, so linking them all OOMs; `ratex` dispatches aliases by name.
    system "cargo", "install", "--bin", "ratex", *std_cargo_args(path: "crates/tex-cli")
    %w[latexdiff lualatex pdflatex tex-bibtex texmk xelatex].each { |cmd| bin.install_symlink "ratex" => cmd }
  end

  test do
    (testpath/"sample.tex").write <<~'LATEX'
      \documentclass{article}

      \title{Test}
      \author{Homebrew}
      \date{\today}

      \begin{document}
        \maketitle

        \section{Example!}

        This is simple \LaTeX file.

      \end{document}
    LATEX

    system bin/"ratex", testpath/"sample.tex"

    assert_path_exists testpath/"sample.pdf"
  end
end
