class XmlToolingC < Formula
  desc "Provides a higher level interface to XML processing"
  homepage "https://wiki.shibboleth.net/confluence/display/OpenSAML/XMLTooling-C"
  url "https://shibboleth.net/downloads/c++-opensaml/3.3.0/xmltooling-3.3.0.tar.bz2"
  sha256 "0a2c421be976f3a44b876d6b06ba1f6a2ffbc404f4622f8a65a66c3ba77cb047"
  license "Apache-2.0"
  revision 4
  compatibility_version 1

  livecheck do
    url "https://shibboleth.net/downloads/c++-opensaml/latest/"
    regex(/href=.*?xmltooling[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "369d012f1c94d28b163bc12fd17b4e51c48bb0eb1e627957e7e775ddebdb8ab7"
  end

  depends_on "pkgconf" => :build
  depends_on "boost"
  depends_on "curl"
  depends_on "log4shib"
  depends_on "openssl@4"
  depends_on "xerces-c"
  depends_on "xml-security-c"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # Apply Ubuntu patch to support OpenSSL 4
  patch do
    url "https://archive.ubuntu.com/ubuntu/pool/universe/x/xmltooling/xmltooling_3.3.0-3ubuntu2.debian.tar.xz"
    sha256 "ec8c5c3729cb90d868ef67f8851d23948e008986cdb986bd118b7dd9a14411a9"
    apply "patches/fix-for-openssl4-compat.patch"
    type :unofficial
  end

  def install
    ENV.cxx11
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"

    inreplace [lib/"pkgconfig/xmltooling.pc", lib/"pkgconfig/xmltooling-lite.pc"], prefix, opt_prefix
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <xmltooling/XMLToolingConfig.h>
      int main() {
        xmltooling::XMLToolingConfig::getConfig().log_config("CRIT");
        xmltooling::XMLToolingConfig::getConfig().init();
        xmltooling::XMLToolingConfig::getConfig().getPathResolver();
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++11", "test.cpp", "-o", "test",
                    "-L#{lib}", "-lxmltooling", "-L#{formula_opt_lib("xerces-c")}", "-lxerces-c"
    output = shell_output("./test 2>&1")
    refute_match("libcurl lacks OpenSSL-specific options", output)
  end
end
