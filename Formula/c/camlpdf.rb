class Camlpdf < Formula
  desc "OCaml library for reading, writing and modifying PDF files"
  homepage "https://github.com/johnwhitington/camlpdf"
  url "https://github.com/johnwhitington/camlpdf/archive/refs/tags/v2.9.2.tar.gz"
  sha256 "1885549dbb2e243b12d1b3752f443efc460400283ce318ec56fbe2f438a57ac8"
  license "LGPL-2.1-only" => { with: "OCaml-LGPL-linking-exception" }

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "1c7faa33b209497a8722e5fc7e1c6e568c4a65b07ffea0df78411d9141560418"
  end

  depends_on "ocaml-findlib" => :build
  depends_on "ocaml"

  def install
    # For OCamlmakefile
    ENV.deparallelize

    # Work around for https://github.com/Homebrew/homebrew-test-bot/issues/805
    if ENV["HOMEBREW_GITHUB_ACTIONS"] && !(Formula["ocaml-findlib"].etc/"findlib.conf").exist?
      ENV["OCAMLFIND_CONF"] = formula_opt_libexec("ocaml-findlib")/"findlib.conf"
    end

    ENV["OCAMLFIND_DESTDIR"] = lib/"ocaml"

    (lib/"ocaml").mkpath
    cp formula_opt_lib("ocaml")/"ocaml/Makefile.config", lib/"ocaml"

    # install in #{lib}/ocaml not #{HOMEBREW_PREFIX}/lib/ocaml
    inreplace lib/"ocaml/Makefile.config" do |s|
      s.change_make_var! "prefix", prefix
    end

    system "make"
    (lib/"ocaml/stublibs").mkpath # `make install` assumes this directory exists
    system "make", "install", "STDLIBDIR=#{lib}/ocaml"

    rm lib/"ocaml/Makefile.config" # avoid conflict with ocaml
  end

  test do
    (testpath/"test.ml").write "Pdfutil.flprint \"camlpdf\""
    system formula_opt_bin("ocaml")/"ocamlopt", "-I", lib/"ocaml/camlpdf", "-I",
           formula_opt_lib("ocaml")/"ocaml", "-o", "test", "camlpdf.cmxa",
           "test.ml"
    assert_match "camlpdf", shell_output("./test")
  end
end
