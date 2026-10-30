class LibtorrentRakshasa < Formula
  desc "BitTorrent library with a focus on high performance"
  homepage "https://github.com/rakshasa/libtorrent"
  url "https://github.com/rakshasa/libtorrent/archive/refs/tags/v0.16.27.tar.gz"
  sha256 "dfef062965b1675e3c21663898eefa31ef18a8bf80c0ab872735c0bf89c4035c"
  license "GPL-2.0-or-later"
  compatibility_version 1

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "e3a7208ff92d27c99c1771407a8d4aab3e75cf3209e48dfe44db2e12f23a32ec"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "openssl@4"

  uses_from_macos "curl"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  conflicts_with "libtorrent-rasterbar", because: "both use the same libname"

  def install
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <iostream>#{"  "}
      #include <torrent/runtime/runtime.h>
      int main(void)
      {
        std::cout << torrent::runtime::version() << std::endl;
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++17", "test.cpp", "-o", "test", "-L#{lib}", "-ltorrent"
    assert_match version.to_s, shell_output("./test").strip
  end
end
