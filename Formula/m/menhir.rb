class Menhir < Formula
  desc "LR(1) parser generator for the OCaml programming language"
  homepage "http://cristal.inria.fr/~fpottier/menhir"
  url "https://gitlab.inria.fr/fpottier/menhir/-/archive/20260209/menhir-20260209.tar.bz2"
  sha256 "06f6e571aadd7d66cc3da808052d9a65f8be96fe27e0ad7e57bbbf8c20f4a832"
  license "GPL-3.0-or-later"
  revision 2

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "37b00377486b95231fadb93b531652aec17a09c62238766b1f0b0b109661edaa"
  end

  depends_on "dune" => :build
  depends_on "ocamlbuild" => :build
  depends_on "ocaml"

  def install
    # Use the release profile like opam so `menhirLib` matches copies bundled by other formulae
    system "dune", "build", "--release", "@install"
    system "dune", "install", "--prefix=#{prefix}", "--mandir=#{man}"
  end

  test do
    (testpath/"test.mly").write <<~EOS
      %token PLUS TIMES EOF
      %left PLUS
      %left TIMES
      %token<int> INT
      %start<int> prog
      %%

      prog: x=exp EOF { x }

      exp: x = INT { x }
      |    lhs = exp; op = op; rhs = exp  { op lhs rhs }

      %inline op: PLUS { fun x y -> x + y }
                | TIMES { fun x y -> x * y }
    EOS

    system bin/"menhir", "--dump", "--explain", "--infer", "test.mly"
    assert_path_exists testpath/"test.ml"
    assert_path_exists testpath/"test.mli"
  end
end
