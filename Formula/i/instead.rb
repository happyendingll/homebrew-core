class Instead < Formula
  desc "Interpreter of simple text adventures"
  homepage "https://instead.hugeping.ru/"
  url "https://github.com/instead-hub/instead/releases/download/3.6.0/instead_3.6.0.tar.gz"
  sha256 "ecc15268824d4cbd1d56ba4e44491069accaebaa642a6d275169878492ede80b"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 sequoia: "dd13869dba2c021dbec8cf05e9b89844ed2bfca437bf9cf55593ee28a07e38ef"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "luajit"
  depends_on "sdl3"
  depends_on "sdl3_image"
  depends_on "sdl3_mixer"
  depends_on "sdl3_ttf"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DWITH_LUAJIT=ON",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/instead -h 2>&1")
  end
end
