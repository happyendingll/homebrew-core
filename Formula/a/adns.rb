class Adns < Formula
  desc "C/C++ resolver library and DNS resolver utilities"
  homepage "https://www.chiark.greenend.org.uk/~ian/adns/"
  url "https://www.chiark.greenend.org.uk/~ian/adns/ftp/adns-1.7.0.tar.gz"
  sha256 "2ffabc4853bb1c70e29e6585ea15dfef8b2bdb86b6ccaad0a3b8c92b5d526d1b"
  license all_of: ["GPL-3.0-or-later", "LGPL-2.0-or-later"]
  head "https://www.chiark.greenend.org.uk/ucgi/~ianmdlvl/githttp/adns.git", branch: "master"

  livecheck do
    url "https://www.chiark.greenend.org.uk/~ian/adns/ftp/"
    regex(/href=.*?adns[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "1cf7679843145b4b2fa0fce9d845d64634a0a005f7cdd936d415f3de88d967f8"
  end

  uses_from_macos "m4" => :build

  # Add missing `<sys/random.h>` header
  patch :DATA

  deny_network_access!

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dynamic"
    system "make"
    system "make", "install"
  end

  test do
    system bin/"adnsheloex", "--version"
  end
end

__END__
diff --git a/src/nextid.c b/src/nextid.c
index c33e175..02508ea 100644
--- a/src/nextid.c
+++ b/src/nextid.c
@@ -21,6 +21,7 @@
  */
 
 #include "internal.h"
+#include <sys/random.h>
 
 /* common, error handling */
