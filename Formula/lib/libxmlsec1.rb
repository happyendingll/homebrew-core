class Libxmlsec1 < Formula
  desc "XML security library"
  homepage "https://www.aleksey.com/xmlsec/"
  url "https://github.com/lsh123/xmlsec/releases/download/1.3.13/xmlsec1-1.3.13.tar.gz"
  mirror "https://www.aleksey.com/xmlsec/download/xmlsec1-1.3.13.tar.gz"
  sha256 "7e500061eed734c55d74c786998e7562e55b1aaa72a2dff8ce3130b4c5b832d5"
  license "MIT"
  compatibility_version 5

  # Checking the first-party download page persistently fails in the autobump
  # environment, so we check GitHub releases as a workaround.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "28ca652781c5ed5d33a7c45368f0df141c452966a31ee2982cb7dd6a85c9864a"
  end

  depends_on "pkgconf" => :build
  depends_on "gnutls" # Yes, it wants both ssl/tls variations
  depends_on "libxml2"
  depends_on "openssl@4"
  uses_from_macos "libxslt"

  def install
    args = %W[
      --disable-apps-crypto-dl
      --disable-crypto-dl
      --disable-mscrypto
      --disable-mscng
      --without-nss
      --without-nspr
      --with-openssl=#{formula_opt_prefix("openssl@4")}
    ]

    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"xmlsec1", "--version"
    system bin/"xmlsec1-config", "--version"
  end
end
