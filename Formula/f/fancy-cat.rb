class FancyCat < Formula
  desc "PDF reader for terminal emulators using the Kitty image protocol"
  homepage "https://github.com/freref/fancy-cat"
  url "https://github.com/freref/fancy-cat/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "c40cd59bef243b3bafa80a33ac97d07c54ab27490d13702abeccbd713f59e37c"
  license "AGPL-3.0-or-later"
  revision 6

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "b2e2d2f2bf7f2c8328008a432ba88f3262bd926a9a52c2c9d32153ece5b6426a"
  end

  depends_on "zig@0.15" => :build
  depends_on "mujs"
  depends_on "mupdf"

  deny_network_access!

  def fetch
    system "zig", "build", "--fetch"
  end

  def install
    system "zig", "build", *std_zig_args
  end

  test do
    # fancy-cat is a TUI application
    assert_match version.to_s, shell_output("#{bin}/fancy-cat --version")
  end
end
