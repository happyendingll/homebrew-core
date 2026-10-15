class Qtdatavis3d < Formula
  desc "Provides functionality for 3D visualization"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.12/6.12.0/submodules/qtdatavis3d-everywhere-src-6.12.0.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/6.12/6.12.0/submodules/qtdatavis3d-everywhere-src-6.12.0.tar.xz"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.12/6.12.0/submodules/qtdatavis3d-everywhere-src-6.12.0.tar.xz"
  sha256 "5f79b948eb1e81ff7f69e335b075c1b48953d88f5d97970b537e348dbbaa98dc"
  license all_of: [
    "GPL-3.0-only",
    "BSD-3-Clause", # *.cmake
  ]
  compatibility_version 1
  head "https://code.qt.io/qt/qtdatavis3d.git", branch: "dev"

  livecheck do
    formula "qtbase"
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "e9116041e6415c85ae07a9d203cb705912ac56a30c19af9b9c6a0376942a4279"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "pkgconf" => :test

  depends_on "qtbase"
  depends_on "qtdeclarative"

  conflicts_with "qt@5", because: "both link conflicting binaries"

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
      project(test VERSION 1.0.0 LANGUAGES CXX)
      find_package(Qt6 REQUIRED COMPONENTS DataVisualization)
      add_executable(test main.cpp)
      target_link_libraries(test PRIVATE Qt6::DataVisualization)
    CMAKE

    (testpath/"test.pro").write <<~QMAKE
      QT      += datavisualization
      TARGET   = test
      CONFIG  += console
      CONFIG  -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    QMAKE

    (testpath/"main.cpp").write <<~CPP
      #undef QT_NO_DEBUG
      #include <QtDataVisualization>

      int main(void) {
        QBar3DSeries series;
        QBarDataRow *data = new QBarDataRow;
        *data << -1.0f << 3.0f << 7.5f << 5.0f << 2.2f;
        series.dataProxy()->addRow(data);
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

    flags = shell_output("pkgconf --cflags --libs Qt6DataVisualization").chomp.split
    system ENV.cxx, "-std=c++17", "main.cpp", "-o", "test", *flags
    system "./test"
  end
end
