class Libfreehand < Formula
  desc "Interpret and import Aldus/Macromedia/Adobe FreeHand documents"
  homepage "https://wiki.documentfoundation.org/DLP/Libraries/libfreehand"
  url "https://dev-www.libreoffice.org/src/libfreehand/libfreehand-0.1.4.tar.xz"
  sha256 "350b10d24a76d7e8c8ae98b74c2d432a2c8ddec08935d09856d20b695a35e600"
  license "MPL-2.0"

  livecheck do
    url "https://dev-www.libreoffice.org/src/"
    regex(/href=["']?libfreehand[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "3c64b110c0b3761b4e3c5387169df34086828f0027a9bce07ff7d4e427af0be3"
  end

  depends_on "boost" => :build
  depends_on "icu4c@78" => :build
  depends_on "pkgconf" => :build
  depends_on "librevenge"
  depends_on "little-cms2"

  uses_from_macos "gperf" => :build

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "./configure", "--without-docs",
                          "--disable-static",
                          "--disable-werror",
                          "--disable-tests",
                          *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <libfreehand/libfreehand.h>
      int main() {
        libfreehand::FreeHandDocument::isSupported(0);
      }
    CPP
    system ENV.cxx, "test.cpp", "-o", "test",
                    "-I#{formula_opt_include("librevenge")}/librevenge-0.0",
                    "-I#{include}/libfreehand-0.1",
                    "-L#{formula_opt_lib("librevenge")}",
                    "-L#{lib}",
                    "-lrevenge-0.0",
                    "-lfreehand-0.1"
    system "./test"
  end
end
