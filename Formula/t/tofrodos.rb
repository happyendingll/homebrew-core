class Tofrodos < Formula
  desc "Converts DOS <-> UNIX text files, alias tofromdos"
  homepage "https://github.com/ChristopherHeng/tofrodos"
  url "https://github.com/ChristopherHeng/tofrodos/archive/refs/tags/3.0.0.tar.gz"
  sha256 "3c2e14a33d704b48cde344540095a09e696f6b7907169ae6f2ff78ab54ad6f8d"
  license "GPL-2.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "557e09fffbc4a376b9aeedaa0a962f0bceef4646e487badfb934b36075a750e9"
  end

  def install
    mkdir_p [bin, man1]

    system "make", "-f", "makefile.gcc", "all"
    system "make", "-f", "makefile.gcc", "BINDIR=#{bin}", "MANDIR=#{man1}", "install"
  end

  test do
    (testpath/"test.txt").write <<~EOS
      Example text
    EOS

    shell_output("#{bin}/todos -b #{testpath}/test.txt")
    shell_output("#{bin}/fromdos #{testpath}/test.txt")
    assert_equal (testpath/"test.txt").read, (testpath/"test.txt.bak").read
  end
end
