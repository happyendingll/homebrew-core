class Mighttpd2 < Formula
  desc "HTTP server"
  homepage "https://kazu-yamamoto.github.io/mighttpd2/"
  url "https://hackage.haskell.org/package/mighttpd2-4.0.11/mighttpd2-4.0.11.tar.gz"
  sha256 "bf8cceeb34339c9357d489b133653c77e8f12a89350bed9e0873f6c1978ef6fc"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "57e48a6ee1b6083f719baa4022a6ec878a85a944f65be61f6d011fc18b406927"
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
