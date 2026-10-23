class Mpck < Formula
  desc "Check MP3 files for errors"
  homepage "https://checkmate.gissen.nl/"
  url "https://checkmate.gissen.nl/checkmate-0.22.tar.gz"
  sha256 "104e5002c4796759c3fdbb987c531f82236bd622399e323b2a406c88ed82cad5"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://checkmate.gissen.nl/download.php"
    regex(/href=.*?checkmate[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "c548fdd791b80aed78b5e8e22b710aca0e13170ec2ef603fd6485eec29b8cd92"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system bin/"mpck", test_fixtures("test.mp3")
  end
end
