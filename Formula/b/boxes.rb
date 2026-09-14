class Boxes < Formula
  desc "Draw boxes around text"
  homepage "https://boxes.thomasjensen.com/"
  url "https://github.com/ascii-boxes/boxes/archive/refs/tags/v2.3.2.tar.gz"
  sha256 "9318ef65f555ee3d893176349a4219f1f1260ce24d4100aeb667a546f61fc183"
  license "GPL-3.0-only"
  head "https://github.com/ascii-boxes/boxes.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "ab526e6048ded427db43d17997670eb11fb1c5a0d8ccd15d8f00809e26966c64"
  end

  depends_on "bison" => :build
  depends_on "libunistring"
  depends_on "pcre2"

  uses_from_macos "flex" => :build
  uses_from_macos "ncurses"

  def install
    # distro uses /usr/share/boxes change to prefix
    system "make", "GLOBALCONF=#{share}/boxes-config",
                   "CC=#{ENV.cc}",
                   "YACC=#{formula_opt_bin("bison")/"bison"}"

    bin.install "out/boxes"
    man1.install "doc/boxes.1"
    share.install "boxes-config"
  end

  test do
    assert_match "test brew", pipe_output(bin/"boxes", "test brew", 0)
  end
end
