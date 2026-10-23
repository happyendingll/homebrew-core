class Pcapmirror < Formula
  desc "Tool for capturing network traffic on remote host using TZSP or ERSPAN"
  homepage "https://git.freestone.net/cramer/pcapmirror"
  url "https://git.freestone.net/cramer/pcapmirror/-/archive/0.7.1/pcapmirror-0.7.1.tar.gz"
  sha256 "b01b56d8515dbcdfb93e48bae171770747ba4772997e388adfc43397ff553232"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "84e90b0b3ccd29d4b6d736a9cf34f5976c44479f9cf74cdbe51ff9f74fb8ce5e"
  end

  depends_on "make" => :build
  uses_from_macos "libpcap"

  on_linux do
    depends_on "libpcap"
  end

  def install
    bin.mkpath
    man8.mkpath
    system "make", "install", "BINDIR=#{bin}", "MANDIR=#{man}"
  end

  test do
    assert_match "Available network interfaces:", shell_output("#{bin}/pcapmirror -l")
  end
end
