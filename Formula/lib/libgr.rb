class Libgr < Formula
  desc "GR framework: a graphics library for visualisation applications"
  homepage "https://gr-framework.org/"
  url "https://github.com/sciapp/gr/archive/refs/tags/v0.73.27.tar.gz"
  sha256 "970cec765c4ef655b428d8af563edfadf21b733aa0530cf7e90ed18b913ee7b0"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "c9361d71c60c79821219c9dbd8f5ec05f8ac706b8f2bedb9f2485a8a747a1087"
  end

  depends_on "cmake" => :build
  depends_on "cairo"
  depends_on "ffmpeg"
  depends_on "freetype"
  depends_on "glfw"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "pixman"
  depends_on "qhull"
  depends_on "qtbase"
  depends_on "zeromq"

  on_linux do
    depends_on "libx11"
    depends_on "libxt"
    depends_on "mesa"
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    # FIXME: macOS 27 SDK's `XPC_INLINE` uses `inline`, which the plugin's strict C90 rejects
    inreplace "CMakeLists.txt", "quartzplugin\n    PROPERTIES C_STANDARD 90",
                                "quartzplugin\n    PROPERTIES C_STANDARD 99"

    system "cmake", "-S", ".", "-B", "build", "-DGR_PREFER_XCODEBUILD=OFF",
                                              "-DCMAKE_INSTALL_RPATH=#{rpath}",
                                              *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <gr.h>

      int main(void) {
          gr_opengks();
          gr_openws(1, "test.png", 140);
          gr_activatews(1);
          double x[] = {0, 0.2, 0.4, 0.6, 0.8, 1.0};
          double y[] = {0.3, 0.5, 0.4, 0.2, 0.6, 0.7};
          gr_polyline(6, x, y);
          gr_axes(gr_tick(0, 1), gr_tick(0, 1), 0, 0, 1, 1, -0.01);
          gr_updatews();
          gr_emergencyclosegks();
          return 0;
      }
    C

    system ENV.cc, "test.c", "-o", "test", "-I#{include}", "-L#{lib}", "-lGR"
    system "./test"

    assert_path_exists testpath/"test.png"
  end
end
