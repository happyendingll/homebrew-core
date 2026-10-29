class Gloox < Formula
  desc "C++ Jabber/XMPP library that handles the low-level protocol"
  homepage "https://camaya.net/gloox/"
  url "https://camaya.net/download/gloox-1.0.28.tar.bz2"
  sha256 "591bd12c249ede0b50a1ef6b99ac0de8ef9c1ba4fd2e186f97a740215cc5966c"
  license "GPL-3.0-only" => { with: "openvpn-openssl-exception" }

  livecheck do
    url :homepage
    regex(/Latest stable version.*?href=.*?gloox[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "1f35a4dbfe4481b1b8e766c6bde77375ca0df77d23294cd851740bbde2599b90"
  end

  depends_on "pkgconf" => :build
  depends_on "gnutls"
  depends_on "libidn"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    system "./configure", "--disable-silent-rules",
                          "--with-zlib",
                          "--without-tests",
                          "--without-examples",
                          *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"gloox-config", "--cflags", "--libs", "--version"
  end
end
