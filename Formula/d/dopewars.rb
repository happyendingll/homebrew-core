class Dopewars < Formula
  desc 'Free rewrite of a game originally based on "Drug Wars"'
  homepage "https://dopewars.sourceforge.io"
  url "https://downloads.sourceforge.net/project/dopewars/dopewars/1.7.0/dopewars-1.7.0.tar.gz"
  sha256 "106dfea6a019b00b69a26044c82d6977296c0c7c684c0c9c256a04ed8adfb20f"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "73121235b13624c2145ab8e9c29f4e69225059b0fd10ac5813869e4f60dac0f9"
  end

  depends_on "pkgconf" => :build

  depends_on "glib"

  uses_from_macos "curl"
  uses_from_macos "ncurses"

  on_macos do
    depends_on "gettext"
  end

  deny_network_access!

  def install
    inreplace "src/Makefile.in", "chmod", "true"
    inreplace "auxbuild/ltmain.sh", "need_relink=yes", "need_relink=no"
    inreplace "src/plugins/Makefile.in", "LIBADD =", "LIBADD = -module -avoid-version"

    system "./configure", "--disable-gui-client",
                          "--disable-gui-server",
                          "--enable-plugins",
                          "--enable-networking",
                          "--mandir=#{man}",
                          *std_configure_args
    system "make", "install", "chgrp=true"
  end

  test do
    system bin/"dopewars", "-v"
  end
end
