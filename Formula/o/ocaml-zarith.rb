class OcamlZarith < Formula
  desc "OCaml library for arbitrary-precision arithmetic"
  homepage "https://github.com/ocaml/Zarith"
  url "https://github.com/ocaml/Zarith/archive/refs/tags/release-1.14.tar.gz"
  sha256 "5db9dcbd939153942a08581fabd846d0f3f2b8c67fe68b855127e0472d4d1859"
  license "LGPL-2.0-only"
  revision 6

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "904490345d71ac8ff7fe8fe55119ffb3cbc0226a44aa862ef97c19625cd723ad"
  end

  depends_on "ocaml-findlib" => :build
  depends_on "gmp"
  depends_on "ocaml"

  def install
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

    ENV.deparallelize
    system "./configure"
    system "make"
    (lib/"ocaml/stublibs").mkpath # `make install` assumes this directory exists
    system "make", "install", "STDLIBDIR=#{lib}/ocaml"

    pkgshare.install "tests"

    rm lib/"ocaml/Makefile.config" # avoid conflict with ocaml
  end

  test do
    cp_r pkgshare/"tests/.", "."
    system formula_opt_bin("ocaml")/"ocamlopt", "-I", lib/"ocaml/zarith",
           "-ccopt", "-L#{lib}/ocaml -L#{formula_opt_lib("gmp")}",
           "zarith.cmxa", "-o", "zq.exe", "zq.ml"
    expected = File.read("zq.output64", mode: "rb")
    assert_equal expected, shell_output("./zq.exe")
  end
end
