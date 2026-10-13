class Libxls < Formula
  desc "Read binary Excel files from C/C++"
  homepage "https://github.com/libxls/libxls"
  url "https://github.com/libxls/libxls/releases/download/v1.6.4/libxls-1.6.4.tar.gz"
  sha256 "064ee1da6cf3d481d8af4a936e0e0ce0190114e468fb7dfef5a81610746081e0"
  license "BSD-2-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "347a8ed13979d8d0e3d31c2c202d4662f49bb092ce02cbcd8d0a1ad1fd89b80f"
  end

  def install
    # Add program prefix `lib` to prevent conflict with another Unix tool `xls2csv`.
    # Arch and Fedora do the same.
    system "./configure", "--disable-silent-rules", "--program-prefix=lib", *std_configure_args
    system "make", "install"
    pkgshare.install "test/files/test2.xls"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <stdlib.h>
      #include <string.h>
      #include <ctype.h>
      #include <xls.h>

      int main(int argc, char *argv[])
      {
          xlsWorkBook* pWB;
          xls_error_t code = LIBXLS_OK;
          pWB = xls_open_file(argv[1], "UTF-8", &code);
          if (pWB == NULL) {
              return 1;
          }
          if (code != LIBXLS_OK) {
              return 2;
          }
          if (pWB->sheets.count != 3) {
              return 3;
          }
          return 0;
      }
    C

    system ENV.cc, "test.c", "-L#{lib}", "-I#{include}", "-lxlsreader", "-o", "test"
    system "./test", pkgshare/"test2.xls"
  end
end
