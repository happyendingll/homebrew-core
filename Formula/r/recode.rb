class Recode < Formula
  desc "Convert character set (charsets)"
  homepage "https://github.com/rrthomas/recode"
  url "https://github.com/rrthomas/recode/releases/download/v3.7.16/recode-3.7.16.tar.gz"
  sha256 "c3d407f54f74bae76360312096e2ed46622f01c86e50b09ef45b2d93c8fcff2d"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "02996a9842cf32a0e4ae3d6b0fb188ea2a824adbc239b04261a7d7c9c22f0766"
  end

  uses_from_macos "python" => :build

  on_macos do
    depends_on "gettext"
  end

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/recode --version")
  end
end
