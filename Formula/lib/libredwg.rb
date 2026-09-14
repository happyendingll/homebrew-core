class Libredwg < Formula
  desc "DWG utilities"
  homepage "https://www.gnu.org/software/libredwg/"
  url "https://ftpmirror.gnu.org/libredwg/libredwg-0.14.tar.gz"
  sha256 "cb6ee0b078c6d9e0f09d66f1feac33ba6342df88ae544e9f9335fab475218351"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "8cb5f8bdcf2c61325a2246353ab16fde517edfd8ed12546da7e135a670d20ed1"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkgconf" => :build
  depends_on "texinfo" => :build

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    resource "testdata" do
      url "https://github.com/LibreDWG/libredwg/raw/refs/heads/master/test/test-data/example_2000.dwg"
      sha256 "34574244d7556d1ef7b437443d9b3d1ad8662e1c669c42d80cff6a8a19799be9"
    end

    resource("testdata").stage do
      system bin/"dwgread", "-o", "example_2000.dxf", "example_2000.dwg"
      assert_path_exists "example_2000.dxf"
    end
  end
end
