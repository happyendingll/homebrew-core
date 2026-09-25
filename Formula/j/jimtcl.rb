class Jimtcl < Formula
  desc "Small footprint implementation of Tcl"
  homepage "https://jim.tcl.tk/index.html"
  url "https://github.com/msteveb/jimtcl/archive/refs/tags/0.84.tar.gz"
  sha256 "435095b436b38b96dd85e8cda13878144813bf52066057f76368db178dd8fea2"
  license "BSD-2-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "a80196991c495b6a52980f16cd4965a5f1f0fb20a3b726f470f2289ba3492516"
  end

  depends_on "pkgconf" => :build
  depends_on "openssl@4"
  depends_on "readline"

  uses_from_macos "sqlite"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "./configure", "--disable-silent-rules",
                          "--with-ext=readline,rlprompt,sqlite3",
                          "--shared",
                          "--docdir=#{doc}",
                          "--ssl",
                          *std_configure_args
    system "make"
    system "make", "install"
    pkgshare.install Dir["examples*"]
  end

  test do
    (testpath/"test.tcl").write "puts {Hello world}"
    assert_match "Hello world", shell_output("#{bin}/jimsh test.tcl")
  end
end
