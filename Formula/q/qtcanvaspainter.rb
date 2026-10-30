class Qtcanvaspainter < Formula
  desc "Accelerated 2D painting solution for Qt Quick and QRhi-based render targets"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.12/6.12.0/submodules/qtcanvaspainter-everywhere-src-6.12.0.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/6.12/6.12.0/submodules/qtcanvaspainter-everywhere-src-6.12.0.tar.xz"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.12/6.12.0/submodules/qtcanvaspainter-everywhere-src-6.12.0.tar.xz"
  sha256 "09c0747c3bef7c58e3154346ca5fe2702ab09f7ad4083243e6d20307245119e2"
  license all_of: [
    "GPL-3.0-only",
    { "GPL-3.0-only" => { with: "Qt-GPL-exception-1.0" } }, # qcshadergen
    "BSD-3-Clause", # *.cmake
    "Zlib", # nanovg
  ]
  revision 1
  compatibility_version 1
  head "https://code.qt.io/qt/qtcanvaspainter.git", branch: "dev"

  livecheck do
    formula "qtbase"
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "319855cb54d4ecefad045cfe0814df0a0eb057f1ee5b2c96db715ac410586e93"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "qtshadertools" => :build
  depends_on "pkgconf" => :test

  depends_on "qtbase"
  depends_on "qtdeclarative"

  def install
    args = ["-DCMAKE_STAGING_PREFIX=#{prefix}"]
    args << "-DQT_NO_APPLE_SDK_AND_XCODE_CHECK=ON" if OS.mac?

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja",
                    *args, *std_cmake_args(install_prefix: HOMEBREW_PREFIX, find_framework: "FIRST")
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink lib.glob("*.framework") if OS.mac?
  end

  test do
    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 4.0)
      project(test LANGUAGES CXX)
      find_package(Qt6 REQUIRED COMPONENTS CanvasPainter)
      add_executable(test main.cpp)
      target_link_libraries(test PRIVATE Qt6::CanvasPainter)
    CMAKE

    (testpath/"test.pro").write <<~QMAKE
      QT      += canvaspainter
      TARGET   = test
      CONFIG  += console
      CONFIG  -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    QMAKE

    (testpath/"main.cpp").write <<~CPP
      #undef QT_NO_DEBUG
      #include <cassert>
      #include <QtCanvasPainter>

      int main(void) {
        QCanvasPath p1;
        QCanvasPath p2;
        assert(p1 == p2);
        p1.moveTo(10, 20);
        assert(p1 != p2);
        p2.moveTo(10, 20);
        assert(p1 == p2);
        return 0;
      }
    CPP

    ENV["LC_ALL"] = "en_US.UTF-8"
    ENV["QT_QPA_PLATFORM"] = "minimal" if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]

    system "cmake", "-S", ".", "-B", "cmake"
    system "cmake", "--build", "cmake"
    system "./cmake/test"

    ENV.delete "CPATH" if OS.mac?
    mkdir "qmake" do
      system formula_opt_bin("qtbase")/"qmake", testpath/"test.pro"
      system "make"
      system "./test"
    end

    flags = shell_output("pkgconf --cflags --libs Qt6CanvasPainter").chomp.split
    system ENV.cxx, "-std=c++17", "main.cpp", "-o", "test", *flags
    system "./test"
  end
end
