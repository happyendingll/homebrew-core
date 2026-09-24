class Libklvanc < Formula
  desc "VANC Processing Framework"
  homepage "https://github.com/stoth68000/libklvanc"
  url "https://github.com/stoth68000/libklvanc/archive/refs/tags/vid.obe.1.7.0.tar.gz"
  sha256 "a1c40c61eb34c98cd9023735b5769b7f43f4b34096149647c8bdf4de937e84c3"
  license "LGPL-2.1-only"
  head "https://github.com/stoth68000/libklvanc.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "5926eee6a492134f500d5e3898863cc598af41a5e659c8368a28146aa5735c2e"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  deny_network_access!

  def install
    system "./autogen.sh", "--build"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <libklvanc/vanc.h>
      int main()
      {
        struct klvanc_context_s *ctx;
        int ret;

        if (klvanc_context_create(&ctx) < 0) return 1;
        klvanc_context_destroy(ctx);
        return 0;
      }
    C

    system ENV.cc, "test.c", "-o", "test", "-I#{include}", "-L#{lib}", "-lklvanc"
    system "./test"

    output = shell_output("#{bin}/klvanc_test_api")
    assert_match(/Total:\s+\d+\s+passed,\s+0\s+failed/, output)
  end
end
