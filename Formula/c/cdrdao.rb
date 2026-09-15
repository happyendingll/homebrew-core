class Cdrdao < Formula
  desc "Record CDs in Disk-At-Once mode"
  homepage "https://cdrdao.sourceforge.net/"
  url "https://github.com/cdrdao/cdrdao/archive/refs/tags/rel_1_2_6.tar.gz"
  sha256 "ba3eadcae7b62a709e9e23988d7fb41f822c408dcec9bd99ff1a343d1bcbc524"
  license "GPL-2.0-or-later"

  livecheck do
    url :stable
    regex(/^rel[._-]v?(\d+(?:[._]\d+)+)$/i)
    strategy :git do |tags, regex|
      tags.filter_map { |tag| tag[regex, 1]&.tr("_", ".") }
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "8eeb287e975c75277be750ae7293f0b39e6c6f44b5be6a79dd232e782c874ae8"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkgconf" => :build
  depends_on "lame"
  depends_on "libao"
  depends_on "libvorbis"
  depends_on "mad"

  def install
    system "./autogen.sh"
    system "./configure", "--mandir=#{man}", *std_configure_args
    system "make", "install"
  end

  test do
    assert_match "ERROR: No device specified, no default device found.",
     shell_output("#{bin}/cdrdao drive-info 2>&1", 1)
  end
end
