class Bmon < Formula
  desc "Interface bandwidth monitor"
  homepage "https://github.com/tgraf/bmon"
  url "https://github.com/Jafaral/bmon/archive/refs/tags/v5.0.tar.gz"
  sha256 "cd7f5fb366a8c32c0e33c79a5daae78edd273993d0edf1036638f269400cf012"
  license "BSD-2-Clause"
  head "https://github.com/tgraf/bmon.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "688a301806e0043ffe7ff8cba526213e232675adcf818791df77e6c8903ca317"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkgconf" => :build
  depends_on "confuse"

  uses_from_macos "ncurses"

  on_linux do
    depends_on "libnl"
  end

  def install
    system "./autogen.sh"
    system "./configure", "--mandir=#{man}", *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"bmon", "-o", "ascii:quitafter=1"
  end
end
