class Multitail < Formula
  desc "Tail multiple files in one terminal simultaneously"
  homepage "https://vanheusden.com/multitail/"
  url "https://github.com/folkertvanheusden/multitail/archive/refs/tags/7.1.6.tar.gz"
  sha256 "bf614c53c212238bccc86bb7ab220b6b11f3997c1900a5767df4b1a79885f421"
  license "MIT"
  head "https://github.com/folkertvanheusden/multitail.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "3be892c49428d3bfe121e2fbfdb962f7da1c018b7d2580656b6c68287d9a5c63"
  end

  depends_on "pkgconf" => :build
  depends_on "ncurses"

  deny_network_access!

  def install
    odie "Check if `inreplace` can be removed" if version > "7.1.6"
    inreplace "version" do |s|
      s.change_make_var! "VERSION", version.to_s
    end
    if OS.linux?
      inreplace "makefile.macosx" do |s|
        cflags = s.get_make_var("CFLAGS") + " -D_LARGEFILE64_SOURCE"
        s.change_make_var! "CFLAGS", cflags
      end
    end
    system "make", "-f", "makefile.macosx", "multitail", "DESTDIR=#{HOMEBREW_PREFIX}"

    bin.install "multitail"
    man1.install Utils::Gzip.compress("multitail.1")
    etc.install "multitail.conf"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/multitail -h 2>&1", 1)
  end
end
