class Conserver < Formula
  desc "Allows multiple users to watch a serial console at the same time"
  homepage "https://www.conserver.com/"
  url "https://github.com/bstansell/conserver/releases/download/v8.3.0/conserver-8.3.0.tar.gz"
  sha256 "202b2ace3e14f36bca4de6ccd43cc962a99853c1d50799672ce0ffc5c02f8404"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "d792776e4df220a5f69d508e3615d3a481ef76f746c56a28bba294ca992edc06"
  end

  depends_on "openssl@4"

  uses_from_macos "krb5"
  uses_from_macos "libxcrypt"

  conflicts_with "uffizzi", because: "both install `console` binaries"

  def install
    system "./configure", "--prefix=#{prefix}", "--with-openssl", "--with-ipv6", "--with-gssapi", "--with-striprealm"
    system "make"
    system "make", "install"
  end

  test do
    console = spawn bin/"console", "-n", "-p", "8000", "test"
    sleep 1
    Process.kill("TERM", console)
    Process.wait(console)
  end
end
