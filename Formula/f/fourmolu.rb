class Fourmolu < Formula
  desc "Formatter for Haskell source code"
  homepage "https://fourmolu.github.io/"
  url "https://hackage.haskell.org/package/fourmolu-0.21.0.0/fourmolu-0.21.0.0.tar.gz"
  sha256 "db321715aa08d24fbf58276dd6f705911d5ced07c00379e9ad10c09aaa064078"
  license "BSD-3-Clause"
  head "https://github.com/fourmolu/fourmolu.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "8170eecc6e8404ac69ecae11af92b4445b1d7810eb747a5ad45426a967203905"
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "gmp"

  uses_from_macos "libffi"

  def install
    system "cabal", "v2-update"
    system "cabal", "v2-install", *std_cabal_v2_args
  end

  test do
    (testpath/"test.hs").write <<~HASKELL
      foo =
        f1
        p1
        p2 p3

      foo' =
        f2 p1
        p2
        p3

      foo'' =
        f3 p1 p2
        p3
    HASKELL
    expected = <<~HASKELL
      foo =
          f1
              p1
              p2
              p3

      foo' =
          f2
              p1
              p2
              p3

      foo'' =
          f3
              p1
              p2
              p3
    HASKELL
    assert_equal expected, shell_output("#{bin}/fourmolu test.hs")
  end
end
