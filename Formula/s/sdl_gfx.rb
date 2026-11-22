class SdlGfx < Formula
  desc "Graphics drawing primitives and other support functions"
  homepage "https://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/"
  url "https://github.com/ferzkopp/SDL_gfx/archive/refs/tags/v2.0.28.tar.gz"
  sha256 "7ed950ae0a5be3be1610bdecaba2fd71c8413927f10e4da267df6d75ea4b35c6"
  license "Zlib"

  livecheck do
    url :homepage
    regex(/href=.*?SDL_gfx[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "9f4c35c3cb5e0e4a22a3e5777fd1ae1f206c9233b45fbcc1db953e676e816701"
  end

  depends_on "cmake" => :build
  depends_on "sdl12-compat"

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <SDL/SDL_imageFilter.h>

      int main()
      {
        int mmx = SDL_imageFilterMMXdetect();
        return 0;
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-lSDL_gfx", "-o", "test"
    system "./test"
  end
end
