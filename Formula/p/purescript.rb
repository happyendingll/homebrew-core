class Purescript < Formula
  desc "Strongly typed programming language that compiles to JavaScript"
  homepage "https://www.purescript.org/"
  # NOTE: If the build fails due to dependency resolution, do not report issue
  # upstream as we modify upstream's constraints in order to use a newer GHC.
  url "https://github.com/purescript/purescript/archive/refs/tags/v0.15.17.tar.gz"
  sha256 "9c397f31c6864491d3f2588acb8e58ecde493c39ec380aaf845458213f1ddab0"
  license "BSD-3-Clause"
  compatibility_version 1
  head "https://github.com/purescript/purescript.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "15b19acdf14240447ea64a87c0e1a2d8da93d3cb1cba9e1b38d46419798dae7b"
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "gmp"

  uses_from_macos "libffi"
  uses_from_macos "ncurses"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  # Minimal set of dependencies that need to be unbound to build with newer GHC
  def args = ["--allow-newer=base,template-haskell"]

  def fetch
    system "cabal", "v2-update"
    system "cabal", "v2-install", "--only-download", *args, *std_cabal_v2_args
  end

  def install
    system "cabal", "v2-install", *args, *std_cabal_v2_args
  end

  test do
    test_module_path = testpath/"Test.purs"
    test_target_path = testpath/"test-module.js"
    test_module_path.write <<~PURESCRIPT
      module Test where

      main :: Int
      main = 1
    PURESCRIPT
    system bin/"purs", "compile", test_module_path, "-o", test_target_path
    assert_path_exists test_target_path
  end
end
