class Libfaketime < Formula
  desc "Report faked system time to programs"
  homepage "https://github.com/wolfcw/libfaketime"
  url "https://github.com/wolfcw/libfaketime/archive/refs/tags/v0.9.13.tar.gz"
  sha256 "8e56deeb805682b025107e095f1d94a6ea677472f05824cd475f5c5e6e1a5ddf"
  license "GPL-2.0-only"
  head "https://github.com/wolfcw/libfaketime.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "73a3ad752912c925652ecc36448fcccb5c53d060d53978e00a173ce0b1d1bd10"
  end

  on_macos do
    # The `faketime` command needs GNU `gdate` not BSD `date`.
    # See https://github.com/wolfcw/libfaketime/issues/158 and
    # https://github.com/Homebrew/homebrew-core/issues/26568
    depends_on "coreutils"
  end

  # upstream bug report, https://github.com/wolfcw/libfaketime/issues/506
  patch :DATA

  def install
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <time.h>

      int main(void) {
        printf("%d\\n",(int)time(NULL));
        return 0;
      }
    C
    system ENV.cc, "test.c", "-o", "test"
    assert_match "1230106542", shell_output("TZ=UTC #{bin}/faketime -f '2008-12-24 08:15:42' ./test").strip
  end
end

__END__
diff --git a/src/Makefile.OSX b/src/Makefile.OSX
index 654fa35..00d50e8 100644
--- a/src/Makefile.OSX
+++ b/src/Makefile.OSX
@@ -80,10 +80,7 @@ all: ${LIBS} ${BINS}
 
 ifeq ($(ARCH),arm64)
 libfaketime.${SONAME}.dylib: libfaketime.c ft_sem.c
-	${CC} -o libfaketime.arm64e.dylib ${CFLAGS} -arch arm64e -fptrauth-calls -fptrauth-returns ${LDFLAGS} ${LIB_LDFLAGS} -install_name ${PREFIX}/lib/faketime/$@ libfaketime.c ft_sem.c
-	${CC} -o libfaketime.arm64.dylib ${CFLAGS} -arch arm64 ${LDFLAGS} ${LIB_LDFLAGS} -install_name ${PREFIX}/lib/faketime/$@ libfaketime.c ft_sem.c
-	lipo -create -output $@ libfaketime.arm64e.dylib libfaketime.arm64.dylib
-	rm libfaketime.arm64e.dylib libfaketime.arm64.dylib
+	${CC} -o $@ ${CFLAGS} -arch arm64 ${LDFLAGS} ${LIB_LDFLAGS} -install_name ${PREFIX}/lib/faketime/$@ libfaketime.c ft_sem.c
 
 faketime: faketime.c ft_sem.c
 	${CC} -o $@ ${CFLAGS} -arch arm64e -arch arm64 ${LDFLAGS} faketime.c ft_sem.c
