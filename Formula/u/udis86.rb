class Udis86 < Formula
  desc "Minimalistic disassembler library for x86"
  homepage "https://sourceforge.net/projects/udis86/"
  url "https://downloads.sourceforge.net/project/udis86/udis86/1.7/udis86-1.7.2.tar.gz"
  sha256 "9c52ac626ac6f531e1d6828feaad7e797d0f3cce1e9f34ad4e84627022b3c2f4"
  license "BSD-2-Clause"
  revision 1

  livecheck do
    url :stable
    regex(%r{url=.*?/udis86[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "3c038dee5f1944c394348a018654d36279c77fb11dbeee5e6519737c7c883840"
  end

  depends_on "python@3.15" => :build

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    file "Patches/libtool/configure-pre-0.4.2.418-big_sur.diff"
    type :unofficial
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--enable-shared",
                          "--with-python=#{python3}"
    system "make"
    system "make", "install"
  end

  test do
    assert_match("int 0x80", pipe_output("#{bin}/udcli -x", "cd 80").split.last(2).join(" "))
  end
end
