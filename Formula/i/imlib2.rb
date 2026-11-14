class Imlib2 < Formula
  desc "Image loading and rendering library"
  homepage "https://sourceforge.net/projects/enlightenment/"
  url "https://downloads.sourceforge.net/project/enlightenment/imlib2-src/1.13.0/imlib2-1.13.0.tar.gz"
  sha256 "97c2ae4401f0a338d2990704a3b71af9a5a0468a8c5d387eb108f2ca1527f4ce"
  license "Imlib2"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 sequoia: "7714af4d323475ecf30f3d2313ccb240d798eea1f9d4ea2b6ac7ec3294b6e43f"
  end

  depends_on "pkgconf" => :build
  depends_on "freetype"
  depends_on "giflib"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "libx11"
  depends_on "libxcb"
  depends_on "libxext"
  depends_on "xz"

  uses_from_macos "bzip2"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    system "./configure", "--disable-silent-rules",
                          "--enable-amd64=no",
                          "--without-heif",
                          "--without-id3",
                          "--without-j2k",
                          "--without-jxl",
                          "--without-ps",
                          "--without-svg",
                          "--without-webp",
                          *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"imlib2_conv", test_fixtures("test.png"), "imlib2_test.png"
  end
end
