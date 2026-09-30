class Libfreefare < Formula
  desc "API for MIFARE card manipulations"
  homepage "https://github.com/nfc-tools/libfreefare"
  url "https://github.com/nfc-tools/libfreefare/releases/download/libfreefare-0.4.0/libfreefare-0.4.0.tar.bz2"
  sha256 "bfa31d14a99a1247f5ed49195d6373de512e3eb75bf1627658b40cf7f876bc64"
  license "LGPL-3.0-or-later"
  revision 4

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "97d7647a2dfcdd24cc87087b4fa67621630318efc5a7dc065f63360a73b35cfd"
  end

  depends_on "pkgconf" => :build
  depends_on "libnfc"
  depends_on "openssl@4"

  on_macos do
    depends_on "libusb-compat"
  end

  # Upstream commit for endianness-related functions
  patch do
    url "https://github.com/nfc-tools/libfreefare/commit/358df775.patch?full_index=1"
    sha256 "20d592c11e559d0a5f02f7ed56da370e39439feebd971be11b064d58ea85777f"
    type :backport
    resolves "https://github.com/nfc-tools/libfreefare/pull/56",
             "https://github.com/nfc-tools/libfreefare/issues/55"
  end

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    file "Patches/libtool/configure-pre-0.4.2.418-big_sur.diff"
  end

  def install
    ENV.append_to_cflags "-I#{formula_opt_include("openssl@4")}"
    ENV.append "LDFLAGS", "-L#{formula_opt_lib("openssl@4")}"

    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <freefare.h>
      int main() {
        mifare_desfire_aid_new(0);
        return 0;
      }
    C

    system ENV.cc, "test.c", "-L#{lib}", "-lfreefare", "-o", "test"
    system "./test"
  end
end
