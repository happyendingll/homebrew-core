class Libwmf < Formula
  desc "Library for converting WMF (Window Metafile Format) files"
  homepage "https://github.com/caolanm/libwmf"
  url "https://github.com/caolanm/libwmf/releases/download/v0.2.16/libwmf-0.2.16.tar.gz"
  sha256 "e20a0bfc2550e779f5f2f13e1afd34cb3b3692954b7e2b73a25ac94c86cb484a"
  license all_of: [
    "LGPL-2.1-or-later",
    "GD", # src/extra/gd
  ]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "f7940bd98530414193af68f7c8cc4986845c6c794399068827184b4c5f35c222"
  end

  depends_on "pkgconf" => :build

  depends_on "freetype"
  depends_on "jpeg-turbo"
  depends_on "libpng"

  uses_from_macos "expat"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "./configure", "--disable-silent-rules",
                          "--with-gsfontdir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts",
                          "--with-gsfontmap=#{HOMEBREW_PREFIX}/share/ghostscript/Resource/Init/Fontmap.GS",
                          "--without-x",
                          *std_configure_args
    system "make", "install"
  end

  test do
    resource "formula1.wmf" do
      url "https://github.com/caolanm/libwmf/raw/3ea3a65ad1b4528ed1c5795071a0142a0e61ec7b/examples/formula1.wmf"
      sha256 "a0d9829692eebfa3bdb23d62f474d58cc4ea2489c07c6fcb63338eb3fb2c14d2"
    end
    resource("formula1.wmf").stage(testpath)

    output = shell_output("#{bin}/wmf2svg --maxwidth=100 --maxheight=100 formula1.wmf")
    assert_match '<svg width="100" height="18"', output

    assert_match version.major_minor_patch.to_s, shell_output("#{bin}/wmf2svg --version 2>&1", 2)
  end
end
