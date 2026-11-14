class Ktexttemplate < Formula
  desc "Libraries for text templating with Qt"
  homepage "https://api.kde.org/ktexttemplate-index.html"
  url "https://download.kde.org/stable/frameworks/6.32/ktexttemplate-6.32.0.tar.xz"
  sha256 "074a1616a41600b358e20c40cab16113906c2394600a4fdc62a22696cc3d4156"
  license "LGPL-2.1-or-later"
  head "https://invent.kde.org/frameworks/ktexttemplate.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 sequoia: "40ea2527b23ab1ee3192b3d8516a43cca8fbadf0d18d345ba971652ed2102415"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "extra-cmake-modules" => :build
  depends_on "qttools" => :build
  depends_on "qtbase"
  depends_on "qtdeclarative"

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    pkgshare.install "examples"
  end

  test do
    system "cmake", pkgshare/"examples/codegen", *std_cmake_args
    system "cmake", "--build", "."
  end
end
