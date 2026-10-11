class Ldapvi < Formula
  desc "Update LDAP entries with a text editor"
  homepage "http://www.lichteblau.com/ldapvi/"
  url "https://github.com/ldapvi/ldapvi/releases/download/1.8/ldapvi-1.8.tar.gz"
  mirror "http://www.lichteblau.com/download/ldapvi-1.8.tar.gz"
  sha256 "359c84d61198c4b4b62930e21670c077c380a41a121f299313330907967949db"
  license "GPL-2.0-or-later"
  revision 1

  livecheck do
    url :homepage
    regex(/href=.*?ldapvi[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "4df22b305aa402608537f69622dbcb1d2d0449c89087902d20241e995a0478e6"
  end

  depends_on "pkgconf" => :build

  depends_on "glib"
  depends_on "libxcrypt" # for crypt.h
  depends_on "openssl@4"
  depends_on "popt"
  depends_on "readline"

  uses_from_macos "ncurses"
  uses_from_macos "openldap"

  on_macos do
    depends_on "gettext"
  end

  def install
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"ldapvi", "--version"
  end
end
