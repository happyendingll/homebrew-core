class Qtremoteobjects < Formula
  desc "Provides APIs for inter-process communication"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.11/6.11.2/submodules/qtremoteobjects-everywhere-src-6.11.2.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/6.11/6.11.2/submodules/qtremoteobjects-everywhere-src-6.11.2.tar.xz"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.11/6.11.2/submodules/qtremoteobjects-everywhere-src-6.11.2.tar.xz"
  sha256 "5e0c9681799ec2b1179a712506266fb01fb2491e94bd2dba942b72fdef797cfd"
  license all_of: [
    { any_of: ["LGPL-3.0-only", "GPL-2.0-only", "GPL-3.0-only"] },
    { "GPL-3.0-only" => { with: "Qt-GPL-exception-1.0" } }, # repc
    "BSD-3-Clause", # *.cmake
  ]
  compatibility_version 1
  head "https://code.qt.io/qt/qtremoteobjects.git", branch: "dev"

  livecheck do
    formula "qtbase"
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "cceb7e4c7022bb23bae18e21c3b631a1f66b0956b3ab93181e225d1669b0189b"
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
      find_package(Qt6 REQUIRED COMPONENTS RemoteObjects)
      add_executable(test main.cpp)
      target_link_libraries(test PRIVATE Qt6::RemoteObjects)
    CMAKE

    (testpath/"test.pro").write <<~QMAKE
      QT      += remoteobjects
      TARGET   = test
      CONFIG  += console
      CONFIG  -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    QMAKE

    (testpath/"main.cpp").write <<~CPP
      #undef QT_NO_DEBUG
      #include <QRemoteObjectRegistryHost>

      int main(void) {
        QRemoteObjectHost node(QUrl(QStringLiteral("local:replica")));
        QRemoteObjectRegistryHost node2(QUrl(QStringLiteral("local:registry")));
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

    flags = shell_output("pkgconf --cflags --libs Qt6RemoteObjects").chomp.split
    system ENV.cxx, "-std=c++17", "main.cpp", "-o", "test", *flags
    system "./test"
  end
end
