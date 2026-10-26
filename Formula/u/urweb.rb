class Urweb < Formula
  desc "Ur/Web programming language"
  homepage "http://www.impredicative.com/ur/"
  url "https://github.com/urweb/urweb/releases/download/20200209/urweb-20200209.tar.gz"
  sha256 "ac3010c57f8d90f09f49dfcd6b2dc4d5da1cdbb41cbf12cb386e96e93ae30662"
  license "BSD-3-Clause"
  revision 13

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "d9b651ce6e6a7437440e8c1614500fa86ec7ce3c29a1496d62fce1629465afc2"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "mlton" => :build
  depends_on "gmp"
  depends_on "icu4c@79"
  depends_on "openssl@4"

  # Patch to fix build for icu4c 68.2
  patch do
    file "Patches/urweb/icu4c68-2.patch"
    type :unofficial
  end

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    file "Patches/libtool/configure-big_sur.diff"
    type :unofficial
  end

  def install
    icu4c = deps.find { |dep| dep.name.match?(/^icu4c(@\d+)?$/) }
                .to_formula
    system "./configure", *std_configure_args,
                          "--disable-silent-rules",
                          "--with-openssl=#{formula_opt_prefix("openssl@4")}",
                          "SITELISP=$prefix/share/emacs/site-lisp/urweb",
                          "ICU_INCLUDES=-I#{icu4c.opt_include}",
                          "ICU_LIBS=-L#{icu4c.opt_lib}"
    system "make", "install"
  end

  test do
    (testpath/"hello.ur").write <<~URS
      fun target () = return <xml><body>
        Welcome!
      </body></xml>
      fun main () = return <xml><body>
        <a link={target ()}>Go there</a>
      </body></xml>
    URS
    (testpath/"hello.urs").write <<~URS
      val main : unit -> transaction page
    URS
    (testpath/"hello.urp").write "hello"
    system bin/"urweb", "hello"
    system "./hello.exe", "-h"
  end
end
