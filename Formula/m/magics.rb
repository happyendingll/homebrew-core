class Magics < Formula
  desc "ECMWF's meteorological plotting software"
  homepage "https://confluence.ecmwf.int/display/MAGP/Magics"
  url "https://confluence.ecmwf.int/download/attachments/3473464/Magics-4.17.1-Source.tar.gz"
  sha256 "a0119c54c812b34a7b190ebf39c546bf523ede6c985e85ff3d41074b11f35598"
  license "Apache-2.0"
  compatibility_version 1

  livecheck do
    url "https://confluence.ecmwf.int/display/MAGP/Releases"
    regex(/href=.*?magics[._-]v?(\d+(?:\.\d+)+)-Source\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 sequoia: "722630079494f0a4ec48ea192edd440692b7260ede3b943593f9482056fda728"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "cairo"
  depends_on "eccodes"
  depends_on "glib"
  depends_on "netcdf"
  depends_on "pango"
  depends_on "proj"
  depends_on "qtbase"

  uses_from_macos "expat"

  on_macos do
    depends_on "gettext"
    depends_on "harfbuzz"
  end

  deny_network_access!

  def install
    # Use --define-prefix to avoid saving Cellar paths in CMake config
    args = %w[
      -DENABLE_METVIEW=ON
      -DENABLE_TESTS=OFF
      -DPKG_CONFIG_ARGN=--define-prefix
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <magics_api.h>

      int main(void) {
        mag_open();
        mag_setc("output_format", "ps");
        mag_setc("output_name", "testc");
        mag_coast();
        mag_close();
        return 0;
      }
    C
    system ENV.cc, "test.c", "-o", "test", "-I#{include}/magics", "-L#{lib}", "-lMagPlus"
    system "./test"
    assert_path_exists testpath/"testc.ps"
  end
end
