class Libetpan < Formula
  desc "Portable mail library handling several protocols"
  homepage "https://www.etpan.org/libetpan.html"
  url "https://github.com/dinhvh/libetpan/archive/refs/tags/2.0.1.tar.gz"
  sha256 "a1bb4bde2791f09ff7ded771ec37584663e6af59e6e64a88dd86e98133cb1238"
  license "BSD-3-Clause"
  compatibility_version 3
  head "https://github.com/dinhvh/libetpan.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "ccd0065632efc863a4d97669af0629134a11656ff303ea085c7a1654b2730801"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "openssl@4"

  uses_from_macos "cyrus-sasl"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    system "./autogen.sh", "--disable-db", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <libetpan/libetpan.h>
      #include <string.h>
      #include <stdlib.h>

      int main(int argc, char ** argv)
      {
        printf("version is %d.%d",libetpan_get_version_major(), libetpan_get_version_minor());
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-letpan", "-o", "test"
    system "./test"
  end
end
