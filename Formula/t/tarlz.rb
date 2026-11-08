class Tarlz < Formula
  desc "Data compressor"
  homepage "https://www.nongnu.org/lzip/tarlz.html"
  url "https://download.savannah.gnu.org/releases/lzip/tarlz/tarlz-0.33.tar.lz"
  mirror "https://download-mirror.savannah.gnu.org/releases/lzip/tarlz/tarlz-0.33.tar.lz"
  sha256 "5df763a8ae2c2bcb94a87294630db2fe3ca827aeb21354d6f2215ed1dcca7970"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://download.savannah.gnu.org/releases/lzip/tarlz/"
    regex(/href=.*?tarlz[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "fbe3abe6b80d58c776cc4ab715523d849763fee48d471c3f2c0ff3b89ad4505e"
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
