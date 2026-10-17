class DuoUnix < Formula
  desc "Two-factor authentication for SSH"
  homepage "https://www.duosecurity.com/docs/duounix"
  url "https://github.com/duosecurity/duo_unix/archive/refs/tags/duo_unix-2.3.0.tar.gz"
  sha256 "f8c53a1beb54f40765c1f5708a6cf6fd4abd94c645d5fdc52e222223d2040092"
  license "GPL-2.0-or-later"
  revision 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "252421bf362be638878b2987c5175c0eb4fa5704a06960895579d279fc609586"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "openssl@4"

  on_linux do
    depends_on "linux-pam"
  end

  # Apply open PR to support OpenSSL 4
  patch do
    url "https://github.com/duosecurity/duo_unix/commit/c17f4845ca553a6cd33f6554aabcf7e726fc167b.patch?full_index=1"
    sha256 "7f1692ba71faddd872b034cce36804f70f5d23a53462dcf4a08f9d0a7ee1293b"
    type :unofficial
    resolves "https://github.com/duosecurity/duo_unix/pull/410"
  end

  deny_network_access!

  def install
    # Darwin declares `strftime_l` in <xlocale.h> rather than <time.h>
    ENV.append_to_cflags "-include xlocale.h" if OS.mac?

    File.write("build-date", time.to_i)
    system "./bootstrap"
    system "./configure", "--disable-silent-rules",
                          "--sysconfdir=#{etc}",
                          "--includedir=#{include}/duo",
                          "--with-openssl=#{formula_opt_prefix("openssl@4")}",
                          "--with-pam=#{lib}/pam/",
                          *std_configure_args
    system "make", "install"
  end

  test do
    system sbin/"login_duo", "-d", "-c", "#{etc}/login_duo.conf",
                             "-f", "foobar", "echo", "SUCCESS"
  end
end
