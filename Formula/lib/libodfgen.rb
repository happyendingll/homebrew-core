class Libodfgen < Formula
  desc "ODF export library for projects using librevenge"
  homepage "https://sourceforge.net/p/libwpd/wiki/libodfgen/"
  url "https://dev-www.libreoffice.org/src/libodfgen-0.1.9.tar.xz"
  mirror "https://downloads.sourceforge.net/project/libwpd/libodfgen/libodfgen-0.1.9/libodfgen-0.1.9.tar.xz"
  sha256 "b68ec10c23b8ac7abed8dfeb181b8592714c1e5bd33997ced0ee8bd6c4612bc5"
  license any_of: ["MPL-2.0", "LGPL-2.1-or-later"]
  compatibility_version 1

  livecheck do
    url "https://dev-www.libreoffice.org/src/"
    regex(/href=["']?libodfgen[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "c5aa43175f1eb32a868fb7f26de35375174aaf8659bc64ffda1f7f410c4e617e"
  end

  depends_on "pkgconf" => :build
  depends_on "librevenge"

  uses_from_macos "libxml2"

  deny_network_access!

  def install
    system "./configure", "--disable-silent-rules",
                          "--disable-static",
                          "--disable-test",
                          "--disable-werror",
                          "--without-docs",
                          *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <libodfgen/OdfDocumentHandler.hxx>
      int main() {
        return ODF_FLAT_XML;
      }
    CPP
    system ENV.cxx, "test.cpp", "-o", "test",
                    "-I#{include}/libodfgen-0.1",
                    "-I#{formula_opt_include("librevenge")}/librevenge-0.0",
                    "-L#{lib}", "-lodfgen-0.1",
                    "-L#{formula_opt_lib("librevenge")}", "-lrevenge-0.0"
    system "./test"
  end
end
