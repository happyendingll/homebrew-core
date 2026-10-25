class Stanc3 < Formula
  desc "Stan transpiler"
  homepage "https://github.com/stan-dev/stanc3"
  url "https://github.com/stan-dev/stanc3.git",
      tag:      "v2.40.0",
      revision: "d58446e631b02cacc5355e373defc6092a684554"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "7bd29d98cbb39bd5fb53e6e7d0a757f8d84d5c93cc0f4bc64cf4e6bed9b29362"
  end

  depends_on "ocaml" => :build
  depends_on "opam" => :build

  uses_from_macos "unzip" => :build

  resource "homebrew-testfile" do
    url "https://raw.githubusercontent.com/stan-dev/stanc3/2e833ac746a36cdde11b7041fe3a1771dec92ba6/test/integration/good/algebra_solver_good.stan"
    sha256 "44e66f05cc7be4d0e0a942b3de03aed1a2c2abd93dbd5607542051d9d6ae2a0b"
  end

  deny_network_access!

  def fetch
    system "opam", "init", "--compiler=ocaml-system", "--disable-sandboxing", "--no-setup"
    # Upstream pins an exact OCaml version, so build against ours instead
    system "opam", "install", ".", "--deps-only", "--download-only", "--ignore-constraints-on=ocaml"
  end

  def install
    system "opam", "install", ".", "--deps-only", "--ignore-constraints-on=ocaml"
    system "opam", "exec", "--", "dune", "subst"
    system "opam", "exec", "--", "dune", "build", "@install"

    bin.install "_build/default/src/stanc/stanc.exe" => "stanc"
  end

  test do
    testpath.install resource("homebrew-testfile")

    system bin/"stanc", "algebra_solver_good.stan"
    assert_path_exists testpath/"algebra_solver_good.hpp"

    assert_match version.to_s, shell_output("#{bin}/stanc --version")
  end
end
