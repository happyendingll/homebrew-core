class Kcgi < Formula
  desc "Minimal CGI and FastCGI library for C/C++"
  homepage "https://kristaps.bsd.lv/kcgi/", browsed: "2026-10-28"
  url "https://github.com/kristapsdz/kcgi/archive/refs/tags/VERSION_1_0_1.tar.gz"
  sha256 "d2b9f377ca31c3ac6ec47e7ec0f46b8f208a33ca80701777a20e355937fc5934"
  license "ISC"
  head "https://github.com/kristapsdz/kcgi.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "11e54cbf85eaf6f7085ce971fb8aa8809325ae81fefad09d850ecbd8df554d75"
  end

  depends_on "bmake" => :build

  on_linux do
    depends_on "libseccomp"
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    system "./configure", "MANDIR=#{man}",
                          "PREFIX=#{prefix}"
    # Uncomment CPPFLAGS to enable libseccomp support on Linux, as instructed to in Makefile.
    inreplace "Makefile", "#CPPFLAGS", "CPPFLAGS" unless OS.mac?
    system "bmake"
    system "bmake", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <sys/types.h>
      #include <stdarg.h>
      #include <stddef.h>
      #include <stdint.h>
      #include <kcgi.h>

      int
      main(void)
      {
        struct kreq r;
        const char *pages = "";

        khttp_parse(&r, NULL, 0, &pages, 1, 0);
        return 0;
      }
    C
    flags = %W[
      -L#{lib}
      -lkcgi
      -lz
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
