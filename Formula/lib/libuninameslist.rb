class Libuninameslist < Formula
  desc "Library of Unicode names and annotation data"
  homepage "https://github.com/fontforge/libuninameslist"
  url "https://github.com/fontforge/libuninameslist/releases/download/20260918/libuninameslist-dist-20260918.tar.gz"
  sha256 "deb2ec02640c232a4bc333c2cd301ee6b286914eeeb0ccc31ccafe326aed0029"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    regex(/v?(\d+(?:\.\d+)*)/i)
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "0cbd20e402ede0c442b856ba917cc52afd56d0d9e12587f07ada5cebbe37fd7b"
  end

  head do
    url "https://github.com/fontforge/libuninameslist.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    if build.head?
      system "autoreconf", "--force", "--install", "--verbose"
      system "automake"
    end

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <uninameslist.h>

      int main() {
        (void)uniNamesList_blockCount();
        return 0;
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-luninameslist", "-o", "test"
    system "./test"
  end
end
