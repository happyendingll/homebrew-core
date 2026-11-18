class Libfaketime < Formula
  desc "Report faked system time to programs"
  homepage "https://github.com/wolfcw/libfaketime"
  url "https://github.com/wolfcw/libfaketime/archive/refs/tags/v0.9.14.tar.gz"
  sha256 "d6468957b11bae8e541524ad43f2cdf91e5d87c8996183897c0499856024c90c"
  license "GPL-2.0-only"
  compatibility_version 1
  head "https://github.com/wolfcw/libfaketime.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 sequoia: "b4d9d7b664214c4e2d74ce9dc6680b815159f88f16d52ba4a007751d6cc998aa"
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
