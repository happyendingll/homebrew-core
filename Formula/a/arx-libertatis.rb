class ArxLibertatis < Formula
  desc "Cross-platform, open source port of Arx Fatalis"
  homepage "https://arx-libertatis.org/"
  url "https://arx-libertatis.org/files/arx-libertatis-1.2.1/arx-libertatis-1.2.1.tar.xz"
  sha256 "aafd8831ee2d187d7647ad671a03aabd2df3b7248b0bac0b3ac36ffeb441aedf"
  license "GPL-3.0-or-later"
  revision 1

  livecheck do
    url "https://arx-libertatis.org/files/"
    regex(%r{href=["']?arx-libertatis[._-]v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "c564b15287f899b63ecb1a08685deb63049deb07ffde8300227a1a91bb8495da"
  end

  head do
    url "https://github.com/arx/ArxLibertatis.git", branch: "master"

    resource "arx-libertatis-data" do
      url "https://github.com/arx/ArxLibertatisData.git", branch: "master"
    end
  end

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "glm" => :build
  depends_on "freetype"
  depends_on "glew"
  depends_on "innoextract"
  depends_on "sdl2-compat"

  on_linux do
    depends_on "mesa"
    depends_on "openal-soft"
    depends_on "zlib-ng-compat"
  end

  conflicts_with "rnv", because: "both install `arx` binaries"

  def install
    args = %w[
      -DBUILD_CRASHREPORTER=OFF
      -DSTRICT_USE=ON
      -DWITH_OPENGL=glew
      -DWITH_SDL=2
    ]
    # Install PNG icons: generating the `.icns` needs `iconutil`, which the build sandbox's mach-lookup policy breaks
    args << "-DICON_TYPE=png"

    # Install prebuilt icons to avoid inkscape and imagemagick deps
    if build.head?
      (buildpath/"arx-libertatis-data").install resource("arx-libertatis-data")
      args << "-DDATA_FILES=#{buildpath}/arx-libertatis-data"
    end

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def caveats
    <<~EOS
      This package only contains the Arx Libertatis binary, not the game data.
      To play Arx Fatalis you will need to obtain the game from GOG.com and
      install the game data with:

        arx-install-data /path/to/setup_arx_fatalis.exe
    EOS
  end

  test do
    output = shell_output("#{bin}/arx --list-dirs")
    assert_match "User directories (select first existing)", output
  end
end
