class OcamlFindlib < Formula
  desc "OCaml library manager"
  homepage "http://projects.camlcity.org/projects/findlib.html"
  url "https://github.com/ocaml/ocamlfind/archive/refs/tags/findlib-1.9.8.tar.gz"
  sha256 "d6899935ccabf67f067a9af3f3f88d94e310075d13c648fa03ff498769ce039d"
  license "MIT"
  revision 5

  livecheck do
    url "https://opam.ocaml.org/packages/ocamlfind/"
    regex(/href=.*?findlib[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "e75d769f04f9aa9e6f909c01de32e76a5533a75031325a3eb12a679e2a93e923"
  end

  depends_on "ocaml"

  uses_from_macos "m4" => :build

  def install
    # Specify HOMEBREW_PREFIX here so those are the values baked into the compile,
    # rather than the Cellar
    system "./configure", "-bindir", bin,
                          "-mandir", man,
                          "-sitelib", HOMEBREW_PREFIX/"lib/ocaml",
                          "-config", etc/"findlib.conf",
                          "-no-camlp4"

    system "make", "all"
    system "make", "opt"

    # Override the above paths for the install step only
    system "make", "install", "OCAML_SITELIB=#{lib}/ocaml",
                              "OCAML_CORE_STDLIB=#{lib}/ocaml"

    # Avoid conflict with ocaml-num package
    rm_r(Dir[lib/"ocaml/num", lib/"ocaml/num-top"])

    # Save extra findlib.conf to work around https://github.com/Homebrew/homebrew-test-bot/issues/805
    libexec.mkpath
    cp etc/"findlib.conf", libexec/"findlib.conf"
  end

  test do
    output = shell_output("#{bin}/ocamlfind query findlib")
    assert_equal "#{HOMEBREW_PREFIX}/lib/ocaml/findlib", output.chomp

    # Check if we need to rebuild ocaml-findlib to be used as a library
    (testpath/"test.ml").write <<~OCAML
      open Findlib;;
      Findlib.init();
    OCAML
    system formula_opt_bin("ocaml")/"ocamlopt", "-I", lib/"ocaml/findlib", "-o", "test", "findlib.cmxa", "test.ml"
    system "./test"
  end
end
