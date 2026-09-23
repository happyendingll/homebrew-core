class Xtermcontrol < Formula
  desc "Control xterm properties such as colors, title, font and geometry"
  homepage "https://thrysoee.dk/xtermcontrol/"
  url "https://thrysoee.dk/xtermcontrol/xtermcontrol-3.11.tar.gz"
  sha256 "49ea6d3eda0dbcf875363763cefe1818ce6786b9910255ea641d9786bdafd44c"
  license "GPL-2.0-or-later"

  livecheck do
    url :homepage
    regex(/href=.*?xtermcontrol[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "62ac1310f15c15d6fe9ca735686dea94facff3fbb7bffdeeb08518d134ab03ca"
  end

  def install
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/xtermcontrol --version")
    expected = "--get-fg is unsupported or disallowed by this terminal"
    assert_match expected, shell_output("#{bin}/xtermcontrol --force --get-fg 2>&1", 1)
  end
end
