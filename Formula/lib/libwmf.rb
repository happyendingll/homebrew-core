class Libwmf < Formula
  desc "Library for converting WMF (Window Metafile Format) files"
  homepage "https://github.com/caolanm/libwmf"
  url "https://github.com/caolanm/libwmf/releases/download/v0.2.17/libwmf-0.2.17.tar.gz"
  sha256 "876915024b64edda8d417daf06819d03a0d18adff1fcc2f64182c69274ed0519"
  license all_of: [
    "LGPL-2.1-or-later",
    "GD", # src/extra/gd
  ]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 sequoia: "4dfef4f88fbbd08c48dd713bc6d595a53199aba705b2843f9d6c161c29caf5e6"
  end

  depends_on "pkgconf" => :build

  depends_on "freetype"
  depends_on "jpeg-turbo"
  depends_on "libpng"

  uses_from_macos "expat"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  resource "formula1.wmf", :test do
    url "https://github.com/caolanm/libwmf/raw/3ea3a65ad1b4528ed1c5795071a0142a0e61ec7b/examples/formula1.wmf"
    sha256 "a0d9829692eebfa3bdb23d62f474d58cc4ea2489c07c6fcb63338eb3fb2c14d2"
  end

  deny_network_access!

  def install
    system "./configure", "--disable-silent-rules",
                          "--with-gsfontdir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts",
                          "--with-gsfontmap=#{HOMEBREW_PREFIX}/share/ghostscript/Resource/Init/Fontmap.GS",
                          "--without-x",
                          *std_configure_args
    system "make", "install"
  end

  test do
    resource("formula1.wmf").stage(testpath)

    output = shell_output("#{bin}/wmf2svg --maxwidth=100 --maxheight=100 formula1.wmf")
    assert_match '<svg width="100" height="18"', output

    assert_match version.major_minor_patch.to_s, shell_output("#{bin}/wmf2svg --version 2>&1", 2)
  end
end
