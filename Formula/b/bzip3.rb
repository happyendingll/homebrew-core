class Bzip3 < Formula
  desc "Better and stronger spiritual successor to BZip2"
  homepage "https://github.com/iczelia/bzip3"
  url "https://github.com/iczelia/bzip3/releases/download/1.5.5/bzip3-1.5.5.tar.gz"
  sha256 "dc3bd8237178e1a2b99d8dcf1f4aeb3593c723788a9863606e121b40784e596d"
  license "LGPL-3.0-only"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "4141a3503aca7429282733f5d51f4777238142add0d2cbae79aa62c521cc43cf"
  end

  depends_on "pkgconf" => :build

  deny_network_access!

  def install
    system "./configure", "--disable-silent-rules", "--disable-arch-native", *std_configure_args
    system "make", "install"
  end

  test do
    testfilepath = testpath/"sample_in.txt"
    zipfilepath = testpath/"sample_in.txt.bz3"

    testfilepath.write "TEST CONTENT"

    system bin/"bzip3", testfilepath
    system bin/"bunzip3", "-f", zipfilepath

    assert_equal "TEST CONTENT", testfilepath.read
  end
end
