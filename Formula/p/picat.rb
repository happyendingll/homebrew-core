class Picat < Formula
  desc "Simple, and yet powerful, logic-based multi-paradigm programming language"
  homepage "https://picat-lang.org/"
  url "https://picat-lang.org/download/picat40_src.tar.gz"
  version "4.0"
  sha256 "aad17a0a6051d783b4920d539cf7b652b0577f0a1e9ab8331f3d176f2abf29e2"
  license "MPL-2.0"

  livecheck do
    url "https://picat-lang.org/download.html"
    regex(/>\s*?Released\s+version\s+v?(\d+(?:[.#]\d+)+)[\s,]/im)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match[0].tr("#", ".") }
    end
  end

  no_autobump! because: :incompatible_version_format

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "c0204099b5a8d510333dda17efb36c9c680d80d4c7939cc52fe7d1ca73656d5e"
  end

  deny_network_access!

  def install
    makefile = if OS.mac?
      "Makefile.mac64"
    else
      ENV.cxx11
      "Makefile.linux64"
    end
    system "make", "-C", "emu", "-f", makefile
    bin.install "emu/picat"
    prefix.install "lib" => "pi_lib"
    doc.install Dir["doc/*"]
    pkgshare.install "exs"
  end

  test do
    output = shell_output("#{bin}/picat #{pkgshare}/exs/euler/p1.pi").chomp
    assert_equal "Sum of all the multiples of 3 or 5 below 1000 is 233168", output
  end
end
