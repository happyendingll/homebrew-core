class Bitwise < Formula
  desc "Terminal based bit manipulator in ncurses"
  homepage "https://github.com/mellowcandle/bitwise"
  url "https://github.com/mellowcandle/bitwise/releases/download/v0.70/bitwise-v0.70.tar.gz"
  sha256 "b8f41f49b9b73ac3abb1e7533a410504f759673fc6e7f35acf56fc82e39cdf37"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "88f5fbc9d25645f59c1e7b3e8643f6137074535e1460e35f52a0dca30e44e4e3"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "readline"

  uses_from_macos "ncurses"

  def install
    # `inc/compat.h` is missing from the release tarball; it only declares strndup/l64a fallbacks
    # Upstream PR ref: https://github.com/mellowcandle/bitwise/pull/71
    inreplace "inc/bitwise.h", "#include \"compat.h\"\n", ""

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"

    system "make", "install"
  end

  test do
    assert_match "0 0 1 0 1 0 0 1", shell_output("#{bin}/bitwise --no-color '0x29A >> 4'")
  end
end
