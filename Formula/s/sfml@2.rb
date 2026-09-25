class SfmlAT2 < Formula
  desc "Multi-media library with bindings for multiple languages"
  homepage "https://www.sfml-dev.org/"
  url "https://www.sfml-dev.org/files/SFML-2.6.2-sources.zip"
  sha256 "19d6dbd9c901c74441d9888c13cb1399f614fe8993d59062a72cfbceb00fed04"
  license "Zlib"
  revision 2

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "9fb446c63b12a765107bd703791d492b752d235831f6b94f4a0c789a5b0aaa0c"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "flac"
  depends_on "freetype"
  depends_on "libogg"
  depends_on "libvorbis"

  on_linux do
    depends_on "libx11"
    depends_on "libxcursor"
    depends_on "libxrandr"
    depends_on "mesa"
    depends_on "mesa-glu"
    depends_on "openal-soft"
    depends_on "systemd"
  end

  # Define character traits for unsigned strings, upstream PR ref, https://github.com/SFML/SFML/pull/3592
  patch do
    url "https://github.com/SFML/SFML/commit/6171cc2a0106b3d1d7aa9ea4e3aff9ca4246f34b.patch?full_index=1"
    sha256 "686bd41e2f1c4fec9d7ef266b65a50862577297056a12c6d5ee507f62dabf11f"
    type :backport
    resolves "https://github.com/SFML/SFML/pull/3592"
  end

  deny_network_access!

  def install
    # Always remove the "extlibs" to avoid install_name_tool failure
    # (https://github.com/Homebrew/homebrew/pull/35279) but leave the
    # headers that were moved there in https://github.com/SFML/SFML/pull/795
    rm_r(Dir["extlibs/*"] - ["extlibs/headers"])

    args = %W[
      -DCMAKE_INSTALL_RPATH=#{lib}
      -DSFML_MISC_INSTALL_PREFIX=#{share}/SFML
      -DSFML_INSTALL_PKGCONFIG_FILES=TRUE
      -DSFML_BUILD_DOC=TRUE
    ]
    args << "-DSFML_USE_SYSTEM_DEPS=ON" if OS.linux?

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include "SFML/System/String.hpp"
      #include "SFML/System/Time.hpp"
      int main() {
        sf::Time t1 = sf::milliseconds(10);
        sf::String text("SFML");
        const auto utf8 = text.toUtf8();
        return t1.asMilliseconds() == 10 && utf8.size() == 4 && utf8[0] == 'S' ? 0 : 1;
      }
    CPP

    system ENV.cxx, testpath/"test.cpp", "-I#{include}", "-L#{lib}", "-lsfml-system", "-o", "test"
    system "./test"
  end
end
