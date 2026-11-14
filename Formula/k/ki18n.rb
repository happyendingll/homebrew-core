class Ki18n < Formula
  desc "KDE Gettext-based UI text internationalization"
  homepage "https://api.kde.org/ki18n-index.html"
  url "https://download.kde.org/stable/frameworks/6.32/ki18n-6.32.0.tar.xz"
  sha256 "b574b381e7510cf3b14d6a16f6ed5670220f10df7f2494c21a579d20ca1d017f"
  license all_of: [
    "BSD-3-Clause",
    "LGPL-2.0-or-later",
    any_of: ["LGPL-2.1-only", "LGPL-3.0-only"],
  ]
  compatibility_version 1
  head "https://invent.kde.org/frameworks/ki18n.git", branch: "master"

  livecheck do
    url "https://download.kde.org/stable/frameworks/"
    regex(%r{href=.*?v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 sequoia: "9a562347fd70a49a475280a0792e18bd5ebdd61e95f21c6c25689d011628ff8e"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "doxygen" => :build
  depends_on "extra-cmake-modules" => [:build, :test]
  depends_on "pkgconf" => :build
  depends_on "qttools" => :build
  depends_on "gettext"
  depends_on "iso-codes"
  depends_on "qtbase"
  depends_on "qtdeclarative"

  uses_from_macos "python" => :build

  deny_network_access!

  def install
    args = %W[
      -DBUILD_QCH=ON
      -DBUILD_WITH_QML=ON
      -DPython3_EXECUTABLE=#{which("python3")}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "autotests"
    (pkgshare/"cmake").install "cmake/FindLibIntl.cmake"
  end

  test do
    qt = Formula["qtbase"]
    qt_major = qt.version.major

    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 4.0)
      include(FeatureSummary)
      find_package(ECM #{version} NO_MODULE)
      set_package_properties(ECM PROPERTIES TYPE REQUIRED)
      set(CMAKE_AUTOMOC ON)
      set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} "#{pkgshare}/cmake")
      set(CMAKE_CXX_STANDARD 17)
      set(QT_MAJOR_VERSION #{qt_major})
      set(BUILD_WITH_QML ON)
      set(REQUIRED_QT_VERSION #{qt.version})
      find_package(Qt${QT_MAJOR_VERSION} ${REQUIRED_QT_VERSION} REQUIRED Core Qml)
      find_package(KF#{qt_major}I18n REQUIRED)
      INCLUDE(CheckCXXSourceCompiles)
      find_package(LibIntl)
      set_package_properties(LibIntl PROPERTIES TYPE REQUIRED)
      add_subdirectory(autotests)
    CMAKE

    cp_r (pkgshare/"autotests"), testpath

    args = if OS.mac?
      %W[
        -DLibIntl_INCLUDE_DIRS=#{formula_opt_include("gettext")}
        -DLibIntl_LIBRARIES=#{formula_opt_lib("gettext")}/libintl.dylib
      ]
    else
      []
    end

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
  end
end
