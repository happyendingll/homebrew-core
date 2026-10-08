class Minidjvu < Formula
  desc "DjVu multipage encoder, single page encoder/decoder"
  homepage "https://minidjvu.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/minidjvu/minidjvu/0.8/minidjvu-0.8.tar.gz"
  sha256 "e9c892e0272ee4e560eaa2dbd16b40719b9797a1fa2749efeb6622f388dfb74a"
  license "GPL-2.0-only"
  revision 1

  livecheck do
    url :stable
    regex(%r{url=.*?/minidjvu[._-]v?((?!0\.33)\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "7457ee46d9b4bbbd4f70239eb97ff70a4746bb36ae7f71f7f2dda12bca40b69c"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "djvulibre"
  depends_on "libtiff"

  on_linux do
    depends_on "gzip"
  end

  deny_network_access!

  def install
    inreplace "Makefile.in", "/usr/bin/gzip", formula_opt_bin("gzip")/"gzip" unless OS.mac?

    ENV.deparallelize
    # force detection of BSD mkdir (macos)
    # outdated configure scripts fail to detect the correct build type (linux arm)
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", *std_configure_args
    system "make"
    system "make", "install"
    lib.install Dir[prefix/shared_library("*")]
  end

  test do
    circle = (0...16).map { |y| (0...16).map { |x| ((((x - 8)**2) + ((y - 8)**2)) < 25) ? 1 : 0 }.join }
    box = (0...16).map { |y| (0...16).map { |x| (x.between?(3, 12) && y.between?(3, 12)) ? 1 : 0 }.join }
    (testpath/"circle.pbm").binwrite "P4\n16 16\n#{[circle.join].pack("B*")}"
    (testpath/"box.pbm").binwrite "P4\n16 16\n#{[box.join].pack("B*")}"

    # Encode a bundled multipage document and decode it back with djvulibre
    system bin/"minidjvu", "circle.pbm", "box.pbm", "out.djvu"
    assert_equal "AT&TFORM", (testpath/"out.djvu").binread(8)

    djvulibre = formula_opt_bin("djvulibre")
    assert_equal "2", shell_output("#{djvulibre}/djvused -e n out.djvu").strip
    system djvulibre/"ddjvu", "-format=pbm", "-page=1", "out.djvu", "page1.pbm"
    system djvulibre/"ddjvu", "-format=pbm", "-page=2", "out.djvu", "page2.pbm"
    assert_equal (testpath/"circle.pbm").binread, (testpath/"page1.pbm").binread
    assert_equal (testpath/"box.pbm").binread, (testpath/"page2.pbm").binread
  end
end
