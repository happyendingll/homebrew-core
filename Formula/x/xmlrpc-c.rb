class XmlrpcC < Formula
  desc "Lightweight RPC library (based on XML and HTTP)"
  homepage "https://xmlrpc-c.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/xmlrpc-c/Xmlrpc-c%20Super%20Stable/1.64.04/xmlrpc-c-1.64.04.tgz"
  sha256 "509c3a3bffb77c81e2c364175ac70b95b799e5b695cc37d4bf833ec28fdfe0b6"
  license "BSD-3-Clause"
  revision 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "e390cbf6dda1872a12a7955d1dd68e583f7f8e23b0185d84f9530f69c4f632ff"
  end

  depends_on "pkgconf" => :build
  depends_on "openssl@4"

  uses_from_macos "curl"
  uses_from_macos "libxml2"

  def install
    # Fix compile with newer Clang
    ENV.append_to_cflags "-Wno-implicit-function-declaration" if DevelopmentTools.clang_build_version >= 1403

    ENV.deparallelize
    # --enable-libxml2-backend to lose some weight and not statically link in expat
    system "./configure", "--enable-libxml2-backend", *std_configure_args
    # xmlrpc-config.h cannot be found if only calling make install
    system "make"
    system "make", "install"
  end

  test do
    system bin/"xmlrpc-c-config", "--features"
  end
end
