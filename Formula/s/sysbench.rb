class Sysbench < Formula
  desc "System performance benchmark tool"
  homepage "https://github.com/akopytov/sysbench"
  url "https://github.com/akopytov/sysbench/archive/refs/tags/1.0.20.tar.gz"
  sha256 "e8ee79b1f399b2d167e6a90de52ccc90e52408f7ade1b9b7135727efe181347f"
  license "GPL-2.0-or-later"
  revision 7
  head "https://github.com/akopytov/sysbench.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "fecc4ffc897872065621262d98534f8d9507f5f0fa932e217cbc051b818ef301"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "libpq"
  depends_on "luajit"
  depends_on "mariadb-connector-c"

  uses_from_macos "vim" # needed for xxd

  def install
    # C23 rejects the K&R-style function definitions in the bundled crc32.c
    ENV.append_to_cflags "-std=gnu17"
    system "./autogen.sh"
    system "./configure", "--with-mysql", "--with-pgsql", "--with-system-luajit", *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"sysbench", "--test=cpu", "--cpu-max-prime=1", "run"
  end
end
