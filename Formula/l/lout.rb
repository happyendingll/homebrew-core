class Lout < Formula
  desc "Text formatting like TeX, but simpler"
  homepage "https://savannah.nongnu.org/projects/lout"
  url "https://github.com/william8000/lout/archive/refs/tags/3.43.5.tar.gz"
  sha256 "4fad5c0a23d42e05e127fa236b1bd60693829d61d98dcf2bec5d80b1a212bdaf"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "e318e86eb70f91a6c2ec896a91b329fcaf752a9e8a99fbb3d93a6031b629f59e"
  end

  def install
    bin.mkpath
    man1.mkpath
    (doc/"lout").mkpath
    system "make", "PREFIX=#{prefix}", "LOUTLIBDIR=#{lib}", "LOUTDOCDIR=#{doc}", "MANDIR=#{man}", "allinstall"
  end

  test do
    input = "test.lout"
    (testpath/input).write <<~EOS
      @SysInclude { doc }
      @Doc @Text @Begin
      @Display @Heading { Blindtext }
      The quick brown fox jumps over the lazy dog.
      @End @Text
    EOS
    assert_match(/^\s+Blindtext\s+The quick brown fox.*\n+$/, shell_output("#{bin}/lout -p #{input}"))
  end
end
