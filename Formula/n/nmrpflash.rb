class Nmrpflash < Formula
  desc "Netgear Unbrick Utility"
  homepage "https://github.com/jclehner/nmrpflash"
  url "https://github.com/jclehner/nmrpflash/archive/refs/tags/v0.9.28.tar.gz"
  sha256 "8d3ec766b7f43bd060032db3cec40c500ef1edc562281f239e308595b66a4176"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "b236b26f10e32e4308032e51b7530fc5dedefb0bf3326cadc0b603b0b78e37c1"
  end

  depends_on "pkgconf" => :build
  uses_from_macos "libpcap"

  on_linux do
    depends_on "libnl"
  end

  def install
    system "make", "install", "PREFIX=#{prefix}", "VERSION=#{version}"
  end

  test do
    system bin/"nmrpflash", "-L"
  end
end
