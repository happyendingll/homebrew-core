class Zvbi < Formula
  desc "Vertical Blanking Interval (VBI) decoding library"
  homepage "https://github.com/zapping-vbi/zvbi"
  url "https://github.com/zapping-vbi/zvbi/archive/refs/tags/v0.2.46.tar.gz"
  sha256 "817a26118e2654155ee761cd39414885986a4315fdb6617af5314090ddfffd10"
  license "GPL-2.0-or-later"
  head "https://github.com/zapping-vbi/zvbi.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "d2506d2d5db5724257164a6d9fd3414a3777742c4af48c0efa4b05889389de34"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gettext" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "libpng"

  on_macos do
    depends_on "gettext"
  end

  deny_network_access!

  def install
    system "./autogen.sh"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <libzvbi.h>
      #include <stdio.h>

      int main() {
        unsigned int major, minor, micro;
        vbi_version(&major, &minor, &micro);
        printf("%u.%u.%u\\n", major, minor, micro);

        vbi_decoder *dec = vbi_decoder_new();
        if (!dec) {
          fprintf(stderr, "vbi_decoder_new failed\\n");
          return 1;
        }
        vbi_decoder_delete(dec);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-lzvbi", "-I#{include}", "-o", "test"
    assert_match version.to_s, shell_output("./test")
  end
end
