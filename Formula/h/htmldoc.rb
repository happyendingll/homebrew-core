class Htmldoc < Formula
  desc "Convert HTML to PDF or PostScript"
  homepage "https://www.msweet.org/htmldoc/"
  url "https://github.com/michaelrsweet/htmldoc/releases/download/v1.9.24/htmldoc-1.9.24-source.zip"
  sha256 "1ae2803f82a4fac7b4f8f80f036d82fdca8f467fb89f4df5d07e7889192e678f"
  license "GPL-2.0-only"
  head "https://github.com/michaelrsweet/htmldoc.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "ab1b89638759df2511cd7e7d226b84cfeff22d48fa1e9e6eb60cdb2f140bd5fd"
  end

  depends_on "pkgconf" => :build
  depends_on "jpeg-turbo"
  depends_on "libpng"

  uses_from_macos "cups"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "./configure", "--without-gui", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    system bin/"htmldoc", "--version"
  end
end
