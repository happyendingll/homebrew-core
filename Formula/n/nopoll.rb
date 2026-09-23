class Nopoll < Formula
  desc "Open-source C WebSocket toolkit"
  homepage "https://www.aspl.es/nopoll/"
  url "https://www.aspl.es/nopoll/downloads/nopoll-0.4.9.b462.tar.gz"
  version "0.4.9.b462"
  sha256 "80bfa3e0228e88e290dd23eb94d9bb1f4d726fb117c11cfb048cbdd1d71d379a"
  license "LGPL-2.1-or-later"

  livecheck do
    url "https://www.aspl.es/nopoll/downloads/"
    regex(/href=.*?nopoll[._-]v?(\d+(?:\.\d+)+(?:\.b\d+)?)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "d6eeb3992c862df2612d210efddddbea55701eeba58f0c7e73e28f8430d1d147"
  end

  depends_on "openssl@4"

  def install
    system "./configure", *std_configure_args, "--disable-silent-rules"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <nopoll.h>
      int main(void) {
        noPollCtx *ctx = nopoll_ctx_new();
        nopoll_ctx_unref(ctx);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-I#{include}/nopoll", "-L#{lib}", "-lnopoll",
           "-o", "test"
    system "./test"
  end
end
