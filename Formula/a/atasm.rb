class Atasm < Formula
  desc "Atari MAC/65 compatible assembler for Unix"
  homepage "https://sourceforge.net/projects/atasm/"
  url "https://github.com/CycoPH/atasm/archive/refs/tags/V1.32.tar.gz"
  sha256 "711af3d28b93046471c04afb09b39fffd16ab57f0129bf02a784ff84cf78f9c6"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "e6de9401c5b43d72701ddcc9c2c06c6a4cd3008a0e5aa34245573ca0b4be8227"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    cd "src" do
      system "make"
      bin.install "atasm"
      inreplace "atasm.1.in", "%%DOCDIR%%", "#{HOMEBREW_PREFIX}/share/doc/atasm"
      man1.install "atasm.1.in" => "atasm.1"
    end
    doc.install "examples", Dir["docs/atasm.*"]
  end

  test do
    cd "#{doc}/examples" do
      system bin/"atasm", "-v", "test.m65", "-o/tmp/test.bin"
    end
  end
end
