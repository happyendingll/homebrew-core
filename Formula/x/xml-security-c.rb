class XmlSecurityC < Formula
  desc "Implementation of primary security standards for XML"
  homepage "https://santuario.apache.org/"
  url "https://shibboleth.net/downloads/xml-security-c/3.0.0/xml-security-c-3.0.0.tar.bz2"
  sha256 "a4c9e1ae3ed3e8dab5d82f4dbdb8414bcbd0199a562ad66cd7c0cd750804ff32"
  license "Apache-2.0"
  revision 1
  compatibility_version 1

  livecheck do
    url "https://shibboleth.net/downloads/xml-security-c/"
    regex(%r{href=["']?v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "5a7c477396f19a6d8295d7dcfd5bdb5d70ff39c780b6f92eecc9034e3b1b30e8"
  end

  depends_on "pkgconf" => :build
  depends_on "openssl@4"
  depends_on "xerces-c"

  # Apply Debian patch to avoid segfault in test
  patch do
    url "https://sources.debian.org/data/main/x/xml-security-c/3.0.0-2/debian/patches/Provide-the-Xerces-URI-Resolver-for-the-tests.patch"
    sha256 "585938480165026990e874fecfae42601dde368f345f1e6ee54b189dbcd01734"
    type :unofficial
  end

  # Apply Ubuntu patch to support OpenSSL 4
  patch do
    url "https://archive.ubuntu.com/ubuntu/pool/universe/x/xml-security-c/xml-security-c_3.0.0-2ubuntu2.debian.tar.xz"
    sha256 "bfbf7ad525046e4b76a91ac034b103da0d63e14118c9778877af5c8f85e62a86"
    apply "patches/fix-for-openssl4-compat.patch"
    type :unofficial
  end

  deny_network_access!

  def install
    system "./configure", "--with-openssl=#{formula_opt_prefix("openssl@4")}", *std_configure_args
    system "make", "install"
  end

  test do
    assert_match "All tests passed", pipe_output("#{bin}/xsec-xtest 2>&1")
  end
end
