class Mighttpd2 < Formula
  desc "HTTP server"
  homepage "https://kazu-yamamoto.github.io/mighttpd2/"
  url "https://hackage.haskell.org/package/mighttpd2-4.0.12/mighttpd2-4.0.12.tar.gz"
  sha256 "958f4f097a889dd128d53951c9dd351f85a88ab8180c3d0be8811eb34060230b"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "a953ccdb89941398079982126cd320a9b49ce3d0edb24a5ff3598f41cfc08d4e"
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "gmp"

  uses_from_macos "libffi"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  # Workaround to build aeson with GHC 9.14, https://github.com/haskell/aeson/issues/1155
  def cabal_args = ["--flags=tls", "--allow-newer=base,containers,template-haskell"]

  def fetch
    system "cabal", "v2-update"
    system "cabal", "v2-install", "--only-download", *cabal_args, *std_cabal_v2_args
  end

  def install
    system "cabal", "v2-install", *cabal_args, *std_cabal_v2_args
  end

  test do
    system bin/"mighty-mkindex"
    assert_predicate testpath/"index.html", :file?
  end
end
