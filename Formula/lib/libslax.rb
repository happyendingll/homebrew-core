class Libslax < Formula
  desc "Implementation of the SLAX language (an XSLT alternative)"
  homepage "https://github.com/Juniper/libslax/wiki"
  url "https://github.com/Juniper/libslax/releases/download/3.1.6/libslax-3.1.6.tar.gz"
  sha256 "e876068b343c54c40872fdb3c06749dd9cc4826f43fe4bd8247743070d51d9fb"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "eb7cf5255c4dcede30dcc7fc2333849e2bec188cf8c7e8895987e896cba7a0d8"
  end

  head do
    url "https://github.com/Juniper/libslax.git", branch: "main"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "bison" => :build
  depends_on "libtool" => :build
  depends_on :macos # needs libxslt built --with-debugger
  depends_on "openssl@4"

  uses_from_macos "curl"
  uses_from_macos "libedit"
  uses_from_macos "libxml2"
  uses_from_macos "libxslt"
  uses_from_macos "sqlite"

  conflicts_with "gastown", "genometools", because: "both install `gt` binaries"
  conflicts_with "libxi", because: "both install `libxi.a`"

  def install
    system "autoreconf", "--force", "--install", "--verbose" if build.head?
    system "./configure", "--disable-silent-rules", "--enable-libedit", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"hello.slax").write <<~EOS
      version 1.0;

      match / {
          expr "Hello World!";
      }
    EOS

    system bin/"slaxproc", "--slax-to-xslt", "hello.slax", "hello.xslt"
    assert_path_exists testpath/"hello.xslt"
    assert_match "<xsl:text>Hello World!</xsl:text>", File.read("hello.xslt")
  end
end
