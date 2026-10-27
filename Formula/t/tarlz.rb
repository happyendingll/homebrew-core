class Tarlz < Formula
  desc "Data compressor"
  homepage "https://www.nongnu.org/lzip/tarlz.html"
  url "https://download.savannah.gnu.org/releases/lzip/tarlz/tarlz-0.32.2.tar.lz"
  mirror "https://download-mirror.savannah.gnu.org/releases/lzip/tarlz/tarlz-0.32.2.tar.lz"
  sha256 "99d456c62a6ffff80527b2bd933af074ded4148c3c99aabd5205d58abd968109"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://download.savannah.gnu.org/releases/lzip/tarlz/"
    regex(/href=.*?tarlz[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "c2fcf12a2bb9edd22f3e28aaecf5156908c2cb58a13c1607ec914147ea160774"
  end

  depends_on "lzlib"

  deny_network_access!

  def install
    system "./configure", *std_configure_args
    system "make"
    ENV.deparallelize
    system "make", "install"
  end

  test do
    archive = testpath/"test.tar.lz"
    (testpath/"source/test.txt").write "TEST CONTENT"
    (dest = testpath/"destination").mkpath

    system bin/"tarlz", "-C", testpath, "-cf", archive, "source"
    assert_path_exists archive

    system bin/"tarlz", "-C", dest, "-xf", archive
    assert_equal "TEST CONTENT", (dest/"source/test.txt").read
  end
end
