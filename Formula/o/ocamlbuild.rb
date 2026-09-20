class Ocamlbuild < Formula
  desc "Generic build tool for OCaml"
  homepage "https://github.com/ocaml/ocamlbuild"
  url "https://github.com/ocaml/ocamlbuild/archive/refs/tags/0.16.1.tar.gz"
  sha256 "2ba6857f2991b7f69368e8db818b163d31cf5a367f15f5953bf8f01a77b3d4fc"
  license "LGPL-2.0-only" => { with: "OCaml-LGPL-linking-exception" }
  revision 2
  head "https://github.com/ocaml/ocamlbuild.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "6524e51c0c8cd66915a3df55275dab90f74b2d93b87463b30a71f4980fc145b2"
  end

  depends_on "ocaml"

  def install
    system "make", "configure", "OCAMLBUILD_BINDIR=#{bin}", "OCAMLBUILD_LIBDIR=#{lib}", "OCAMLBUILD_MANDIR=#{man}"
    system "make"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ocamlbuild --version")
  end
end
