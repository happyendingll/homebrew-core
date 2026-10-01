class Libmd < Formula
  desc "Message Digest functions from BSD systems"
  homepage "https://www.hadrons.org/software/libmd/"
  url "https://archive.hadrons.org/software/libmd/libmd-1.3.0.tar.xz"
  mirror "https://libbsd.freedesktop.org/releases/libmd-1.3.0.tar.xz"
  sha256 "fc0f1eb6b6766470326f2c014693809190e67dba84274a6fbae9d4912d066706"
  license all_of: ["BSD-3-Clause", "BSD-2-Clause", "ISC", "Beerware", :public_domain]

  livecheck do
    url "https://archive.hadrons.org/software/libmd/"
    regex(/href=.*?libmd[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "ba831a1212e849a471791812676bfaa1636ee7a5793c7098ce2960812bc95e36"
  end

  head do
    url "https://git.hadrons.org/git/libmd.git", branch: "main"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    system "./autogen" if build.head?
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdlib.h>
      #include <stdio.h>
      #include <string.h>
      #include <md5.h>

      int main() {
          MD5_CTX ctx;
          uint8_t results[MD5_DIGEST_LENGTH];
          char *buf;
          buf = "abc";
          int n;
          n = strlen(buf);
          MD5Init(&ctx);
          MD5Update(&ctx, (uint8_t *)buf, n);
          MD5Final(results, &ctx);
          for (n = 0; n < MD5_DIGEST_LENGTH; n++)
              printf("%02x", results[n]);
          putchar('\\n');
          return EXIT_SUCCESS;
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lmd", "-o", "test"
    assert_equal "900150983cd24fb0d6963f7d28e17f72", shell_output("./test").chomp
  end
end
