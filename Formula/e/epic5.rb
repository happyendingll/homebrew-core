class Epic5 < Formula
  desc "Enhanced, programmable IRC client"
  homepage "https://www.epicsol.org/"
  url "https://ftp.epicsol.org/pub/epic/EPIC5-PRODUCTION/epic5-3.0.3.tar.xz"
  mirror "https://www.mirrorservice.org/sites/distfiles.macports.org/epic5/epic5-3.0.3.tar.xz"
  sha256 "63a411215c14040b65b5d728aff10f7523d55e170f6298fb01e1cf958d79d326"
  license "BSD-3-Clause"
  head "https://git.epicsol.org/epic5.git", branch: "master"

  livecheck do
    url "https://ftp.epicsol.org/pub/epic/EPIC5-PRODUCTION/"
    regex(/href=.*?epic5[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "e9411e19e2c7e0749a3f6ea15b08fca341f33ceb3d4e13187621cfe83b09c2d4"
  end

  depends_on "openssl@4"

  uses_from_macos "libxcrypt"
  uses_from_macos "ncurses"

  def install
    system "./configure", "--mandir=#{man}",
                          "--with-ipv6",
                          "--with-ssl=#{formula_opt_prefix("openssl@4")}",
                          *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    connection = spawn bin/"epic5", "irc.freenode.net"
    sleep 5
    Process.kill("TERM", connection)
    Process.wait(connection)
  end
end
