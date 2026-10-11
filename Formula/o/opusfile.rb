class Opusfile < Formula
  desc "API for decoding and seeking in .opus files"
  homepage "https://www.opus-codec.org/"
  url "https://ftp.osuosl.org/pub/xiph/releases/opus/opusfile-0.12.tar.gz"
  mirror "https://github.com/xiph/opusfile/releases/download/v0.12/opusfile-0.12.tar.gz"
  sha256 "118d8601c12dd6a44f52423e68ca9083cc9f2bfe72da7a8c1acb22a80ae3550b"
  license "BSD-3-Clause"
  revision 3

  livecheck do
    url "https://ftp.osuosl.org/pub/xiph/releases/opus/"
    regex(%r{href=(?:["']?|.*?/)opusfile[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "df9296692564fa61956ee06ffe123a9493ea391c2984919fc3986d35b4cf6457"
  end

  head do
    url "https://gitlab.xiph.org/xiph/opusfile.git", branch: "main"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "libogg"
  depends_on "openssl@4"
  depends_on "opus"

  resource "sample" do
    url "https://dl.espressif.com/dl/audio/gs-16b-1c-44100hz.opus"
    sha256 "f80fabebe4e00611b93019587be9abb36dbc1935cb0c9f4dfdf5c3b517207e1b"
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    resource("sample").stage { testpath.install Pathname.pwd.children(false).first => "sample.opus" }
    (testpath/"test.c").write <<~C
      #include <opus/opusfile.h>
      #include <stdlib.h>
      int main(int argc, const char **argv) {
        int ret;
        OggOpusFile *of;

        of = op_open_file(argv[1], &ret);
        if (of == NULL) {
          fprintf(stderr, "Failed to open file '%s': %i\\n", argv[1], ret);
          return EXIT_FAILURE;
        }
        op_free(of);
        return EXIT_SUCCESS;
      }
    C
    system ENV.cc, "test.c", "-I#{formula_opt_include("opus")}/opus",
                             "-L#{lib}",
                             "-lopusfile",
                             "-o", "test"
    system "./test", "sample.opus"
  end
end
