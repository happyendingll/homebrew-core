class Isync < Formula
  desc "Synchronize a maildir with an IMAP server"
  homepage "https://isync.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/isync/isync/1.5.1/isync-1.5.1.tar.gz"
  sha256 "28cc90288036aa5b6f5307bfc7178a397799003b96f7fd6e4bd2478265bb22fa"
  license "GPL-2.0-or-later"
  revision 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "8c20671ba7cfe8ec9b6d3baaecefc272676b8807c36dcf63ef8feb4ff477e027"
  end

  head do
    url "https://git.code.sf.net/p/isync/isync.git", branch: "master"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "berkeley-db@5"
  depends_on "openssl@4"

  uses_from_macos "cyrus-sasl"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # Backport fix for OpenSSL 4
  # https://sourceforge.net/p/isync/isync/ci/bdd9ff8d931236e1926a58cb44bd2644e4538217/
  patch do
    file "Patches/isync/openssl-4.diff"
    type :backport
  end

  deny_network_access!

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  service do
    run [opt_bin/"mbsync", "-a"]
    run_type :interval
    interval 300
    keep_alive false
    environment_variables PATH: std_service_path_env
    log_path File::NULL
    error_log_path File::NULL
  end

  test do
    system bin/"mbsync-get-cert", "duckduckgo.com:443"
  end
end
