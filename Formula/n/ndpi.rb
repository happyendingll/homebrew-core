class Ndpi < Formula
  desc "Deep Packet Inspection (DPI) library"
  homepage "https://www.ntop.org/products/deep-packet-inspection/ndpi/"
  url "https://github.com/ntop/nDPI/archive/refs/tags/6.0.tar.gz"
  sha256 "21fc40cab5505942c0b21d9bbaf73e9adf8162ddfe782e4cd072cab855a2eda9"
  license "LGPL-3.0-or-later"
  compatibility_version 1
  head "https://github.com/ntop/nDPI.git", branch: "dev"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "91cfec0ecf02f7d4c39289ccfd7aed1817d80af3ba3fb21977a614bb0cfc1ca0"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "json-c"

  uses_from_macos "libpcap"

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system bin/"ndpiReader", "-i", test_fixtures("test.pcap")
  end
end
