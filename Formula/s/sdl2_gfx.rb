class Sdl2Gfx < Formula
  desc "SDL2 graphics drawing primitives and other support functions"
  homepage "https://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/"
  url "https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-1.1.0.tar.gz"
  mirror "https://downloads.sourceforge.net/project/sdl2gfx/SDL2_gfx-1.1.0.tar.gz"
  sha256 "9843924d46eacbabba685a239cf2284b948766a20ef2caa48cb18462a3295caf"
  license "Zlib"
  compatibility_version 1

  livecheck do
    url :homepage
    regex(/href=.*?SDL2_gfx[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "cad243fb24bd2925f1639a4362c65e1bb6a6abcf7960dce5a5ccfca65b8a7a5a"
  end

  depends_on "sdl2-compat"

  deny_network_access!

  def install
    args = []
    args << "--disable-mmx" if Hardware::CPU.arm?

    # Help old config scripts identify arm64 linux
    args << "--build=aarch64-unknown-linux-gnu" if OS.linux? && Hardware::CPU.arm64?

    # Workaround to avoid undefined references with `sdl2-compat`.
    # Not actively maintained with last activity in 2018
    ENV.append "LIBS", "-lm" if OS.linux?

    system "./configure", "--disable-sdltest", *args, *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <SDL2/SDL2_imageFilter.h>

      int main()
      {
        int mmx = SDL_imageFilterMMXdetect();
        return 0;
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-lSDL2_gfx", "-o", "test"
    system "./test"
  end
end
