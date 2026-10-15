class Yosys < Formula
  desc "Framework for Verilog RTL synthesis"
  homepage "https://yosyshq.net/yosys/"
  url "https://github.com/YosysHQ/yosys/releases/download/v0.70/yosys.tar.gz"
  sha256 "c6bd8b83aad633f6786fc861fe8f5dbc74c37bfae77f7bd0220e6f00f15f1d55"
  license "ISC"
  head "https://github.com/YosysHQ/yosys.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 sequoia: "e70897c850361cfb92540db95fdd659ad718a5962517aee57b5207a8b99614de"
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
