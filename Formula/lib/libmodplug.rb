class Libmodplug < Formula
  desc "Library from the Modplug-XMMS project"
  homepage "https://modplug-xmms.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/modplug-xmms/libmodplug/0.8.9.2/libmodplug-0.8.9.2.tar.gz"
  sha256 "e4d9cb46da78a639d6eadb4ff3ab955f68c3099579b5310af64b37091e28957e"
  license :public_domain
  compatibility_version 1

  livecheck do
    url :stable
    regex(%r{url=.*?/libmodplug[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "8fc85d7c6d264b5e20bf750f961263facfc9b39ba756b3a3617bb802fe909236"
  end

  resource "testmod", :test do
    # Most favourited song on modarchive:
    # https://modarchive.org/index.php?request=view_by_moduleid&query=212083
    url "https://api.modarchive.org/downloads.php?moduleid=212083#2nd_pm.s3m"
    sha256 "b869c3e70c66010eda066452791cc3f1536bd3ad0bc01b98924c79765b03ceb2"
  end

  deny_network_access!

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--enable-static",
                          "--prefix=#{prefix}"

    system "make", "install"
  end

  test do
    # First a basic test just that we can link on the library
    # and call an initialization method.
    (testpath/"test_null.cpp").write <<~CPP
      #include "libmodplug/modplug.h"
      int main() {
        ModPlugFile* f = ModPlug_Load((void*)0, 0);
        if (!f) {
          // Expecting a null pointer, as no data supplied.
          return 0;
        } else {
          return -1;
        }
      }
    CPP
    system ENV.cc, "test_null.cpp", "-L#{lib}", "-lmodplug", "-o", "test_null"
    system "./test_null"

    # Second, acquire an actual music file from a popular internet
    # source and attempt to parse it.
    resource("testmod").stage testpath
    (testpath/"test_mod.cpp").write <<~CPP
      #include "libmodplug/modplug.h"
      #include <fstream>
      #include <sstream>

      int main() {
        std::ifstream in("2nd_pm.s3m");
        std::stringstream buffer;
        buffer << in.rdbuf();
        int length = buffer.tellp();
        ModPlugFile* f = ModPlug_Load(buffer.str().c_str(), length);
        if (f) {
          // Expecting success
          return 0;
        } else {
          return -1;
        }
      }
    CPP
    system ENV.cxx, "test_mod.cpp", "-L#{lib}", "-lmodplug", "-o", "test_mod"
    system "./test_mod"
  end
end
