class Sdl3Mixer < Formula
  desc "Sample multi-channel audio mixer library"
  homepage "https://github.com/libsdl-org/SDL_mixer"
  url "https://github.com/libsdl-org/SDL_mixer/releases/download/release-3.2.4/SDL3_mixer-3.2.4.tar.gz"
  sha256 "182a07c745375e113dc740d43964ff21b0be29f29f59876c4dbc4db3d32f6901"
  license "Zlib"
  revision 1
  head "https://github.com/libsdl-org/SDL_mixer.git", branch: "main"

  livecheck do
    url :stable
    regex(/^(?:release[._-])?v?(3(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "d2493aa71578b97404ea08d4f7f6dc12a1569ba17f545ce40b6cf5515f66bf2a"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "flac"
  depends_on "fluid-synth"
  depends_on "game-music-emu"
  depends_on "libvorbis"
  depends_on "libxmp"
  depends_on "mpg123"
  depends_on "opusfile"
  depends_on "sdl3"
  depends_on "wavpack"

  deny_network_access!

  def install
    args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DSDLMIXER_STRICT=ON
      -DSDLMIXER_DEPS_SHARED=OFF
      -DSDLMIXER_VENDORED=OFF
      -DSDLMIXER_EXAMPLES=OFF
      -DSDLMIXER_TESTS=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <SDL3_mixer/SDL_mixer.h>
      #include <stdlib.h>

      int main()
      {
          int result = MIX_Init();
          MIX_Quit();
          return result != 0 ? EXIT_SUCCESS : EXIT_FAILURE;
      }
    C
    system ENV.cc, "test.c", "-o", "test", "-I#{include}", "-L#{lib}", "-lSDL3_mixer"
    system "./test"
  end
end
