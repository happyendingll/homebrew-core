class Libretls < Formula
  desc "Libtls for OpenSSL"
  homepage "https://git.causal.agency/libretls/about/"
  url "https://causal.agency/libretls/libretls-3.8.1.tar.gz"
  sha256 "3bc9fc0e61827ee2f608e5e44993a8fda6d610b80a1e01a9c75610cc292997b5"
  license "ISC"
  revision 1
  compatibility_version 1

  livecheck do
    url "https://causal.agency/libretls/"
    regex(/href=.*?libretls[._-]v?(\d+(?:\.\d+)+(?:p\d+)?)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "f5058e1b42b52075e14ad64005b60cdfcb976fd9c2d5d4d2ab35828774e10e85"
  end

  depends_on "openssl@4"

  def install
    system "./configure", *std_configure_args,
                          "--disable-silent-rules",
                          "--with-openssl=#{formula_opt_prefix("openssl@4")}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <tls.h>
      int main() {
        return tls_init();
      }
    C
    system ENV.cc, "test.c", "-o", "test", "-L#{lib}", "-ltls"
    system "./test"
  end
end
