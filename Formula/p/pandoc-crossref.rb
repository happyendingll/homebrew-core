class PandocCrossref < Formula
  desc "Pandoc filter for numbering and cross-referencing"
  homepage "https://lierdakil.github.io/pandoc-crossref/"
  url "https://github.com/lierdakil/pandoc-crossref/archive/refs/tags/v0.3.25a.tar.gz"
  version "0.3.25a"
  sha256 "91712810bf91807869dbda35f5186cd4f39352c6201d5712c8f4ce1ac3691ab5"
  license "GPL-2.0-or-later"
  revision 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "1e91aac310fafb8b22c2d24c22776f67a5065e4fbea0243d4d23e67d790a9146"
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "gmp"
  depends_on "pandoc"

  uses_from_macos "unzip" => :build
  uses_from_macos "libffi"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # Relax the pandoc bound so the filter is compiled against pandoc 3.12
  patch do
    url "https://github.com/daeho-ro/pandoc-crossref/commit/5709f41df96ab5a7ca6d573e5695d10fc0db2928.patch?full_index=1"
    sha256 "6ad18e41d5b89dd58cf452ccc83a9a6f1dcbb16562a954c86e328ea0306ec43f"
    type :unofficial
    resolves "https://github.com/lierdakil/pandoc-crossref/pull/514"
  end

  def install
    rm("cabal.project.freeze")

    # Workaround to build aeson with GHC 9.14, https://github.com/haskell/aeson/issues/1155
    args = ["--allow-newer=base,containers,template-haskell"]

    system "cabal", "v2-update"
    system "cabal", "v2-install", *args, *std_cabal_v2_args
  end

  test do
    (testpath/"hello.md").write <<~MARKDOWN
      Demo for pandoc-crossref.
      See equation @eq:eqn1 for cross-referencing.
      Display equations are labelled and numbered

      $$ P_i(x) = \\sum_i a_i x^i $$ {#eq:eqn1}
    MARKDOWN
    output = shell_output("#{formula_opt_bin("pandoc")}/pandoc -F #{bin}/pandoc-crossref -o out.html hello.md 2>&1")
    assert_match "∑", (testpath/"out.html").read
    refute_match "WARNING: pandoc-crossref was compiled", output
  end
end
