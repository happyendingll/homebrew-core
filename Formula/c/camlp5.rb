class Camlp5 < Formula
  desc "Preprocessor and pretty-printer for OCaml"
  homepage "https://camlp5.github.io/"
  url "https://github.com/camlp5/camlp5/archive/refs/tags/8.05.02.tar.gz"
  sha256 "ceceb2377563f5483738090b614447536daa4cea119dc768a0659543727b4497"
  license "BSD-3-Clause"
  revision 2
  head "https://github.com/camlp5/camlp5.git", branch: "master"

  livecheck do
    url "https://opam.ocaml.org/packages/camlp5/"
    regex(%r{href=.*?/refs/tags/(?:rel[._-]?)?v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "3746a159ae20804c9babddfcd5caeec701e19da4feebf46bab15aa2e204aa428"
  end

  depends_on "ocaml-findlib" => :build
  depends_on "opam" => :build
  depends_on "pkgconf" => :build
  depends_on "camlp-streams"
  depends_on "ocaml"
  depends_on "pcre2"

  uses_from_macos "m4" => :build

  def install
    ENV["OPAMROOT"] = opamroot = buildpath/".opam"
    ENV["OPAMYES"] = "1"

    system "opam", "init", "--compiler=ocaml-system", "--disable-sandboxing", "--no-setup"
    system "opam", "install", ".", "--deps-only", "--yes", "--no-depexts"

    # OCaml 5.5.0 no longer exposes opam's C stubs (e.g. dllpcre2_stubs.so) for linking.
    # https://github.com/ocaml/opam-repository/issues/16406
    ENV.prepend_path "CAML_LD_LIBRARY_PATH", opamroot/"ocaml-system/lib/stublibs"

    system "./configure", "--prefix", prefix, "--libdir", lib/"ocaml", "--mandir", man
    system "opam", "exec", "--", "make", "world.opt"
    system "opam", "exec", "--", "make", "install"
    (lib/"ocaml/camlp5").install "etc/META"
    libexec.install opamroot/"ocaml-system/lib/stublibs/dllpcre2_stubs.so"
    bin.env_script_all_files libexec, CAML_LD_LIBRARY_PATH: libexec
  end

  test do
    ocaml = Formula["ocaml"]
    (testpath/"hi.ml").write "print_endline \"Hi!\";;"
    assert_equal "let _ = print_endline \"Hi!\"",
      # The purpose of linking with the file "str.cma" is to ensure that the
      # ocaml files are in sync with the camlp5 files.  If camlp5 has been
      # compiled with an older version of the ocaml compiler, then an error
      # "interface mismatch" will occur.
      shell_output("#{bin}/camlp5 #{lib}/ocaml/camlp5/pa_o.cmo " \
                   "#{lib}/ocaml/camlp5/o_keywords.cmo " \
                   "#{lib}/ocaml/camlp5/pr_o.cmo " \
                   "#{ocaml.opt_lib}/ocaml/str/str.cma hi.ml")
  end
end
