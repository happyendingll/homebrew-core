class Yosys < Formula
  desc "Framework for Verilog RTL synthesis"
  homepage "https://yosyshq.net/yosys/"
  url "https://github.com/YosysHQ/yosys/releases/download/v0.71/yosys.tar.gz"
  sha256 "2ec7c2ee63bb9b4065d6d5fff2786a1455e834f90ede8eb1d47791153ebef2a5"
  license "ISC"
  compatibility_version 1
  head "https://github.com/YosysHQ/yosys.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 sequoia: "4c5beb7551951dab06eb61af19aaf3ac2ed0b416e99bdfe401c5368fd45855b8"
  end

  depends_on "bison" => :build
  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "flex" => :build
  depends_on "pkgconf" => :build
  depends_on "fmt"
  depends_on "libtommath"
  depends_on "readline"
  depends_on "tcl-tk"
  depends_on "tomlplusplus"

  uses_from_macos "libffi"
  uses_from_macos "python"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    # Avoid shim reference
    inreplace ["cmake/YosysVersion.cmake", "cmake/YosysConfigScript.cmake"],
              "${CMAKE_CXX_COMPILER}", ENV.cxx

    args = %w[
      -DYOSYS_WITHOUT_EDITLINE=ON
      -DYOSYS_WITHOUT_SLANG=ON
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system bin/"yosys", "-p", "hierarchy; proc; opt; techmap; opt;", "-o", "synth.v", pkgshare/"adff2dff.v"
  end
end
