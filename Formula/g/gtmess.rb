class Gtmess < Formula
  desc "Console MSN messenger client"
  homepage "https://gtmess.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/gtmess/gtmess/0.97/gtmess-0.97.tar.gz"
  sha256 "606379bb06fa70196e5336cbd421a69d7ebb4b27f93aa1dfd23a6420b3c6f5c6"
  license "GPL-2.0-or-later"
  revision 2

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "a95125abe6ba6020632787cd87269e0f4fd82658d16cdf48fc9cbbd01bd4fe7c"
  end

  head do
    url "https://github.com/geotz/gtmess.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "openssl@4"

  uses_from_macos "ncurses"

  deny_network_access!

  def install
    # Workaround for newer Clang
    ENV.append_to_cflags "-Wno-implicit-int" if DevelopmentTools.clang_build_version >= 1403

    system "autoreconf", "--force", "--install", "--verbose" if build.head?
    system "./configure", "--with-ssl=#{formula_opt_prefix("openssl@4")}", *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"gtmess", "--version"
  end
end
