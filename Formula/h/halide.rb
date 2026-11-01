class Halide < Formula
  desc "Language for fast, portable data-parallel computation"
  homepage "https://halide-lang.org"
  url "https://github.com/halide/Halide/archive/refs/tags/v22.1.0.tar.gz"
  sha256 "35b59f91be6189645abf33078b1954740a434d97aaeaeaf5f15d162d86b74f6e"
  license "MIT"
  head "https://github.com/halide/Halide.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+(?:\.post\d+)?)$/i)
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "ba7a7e5783a066e3d0bc431eecb1a0142b22d53515346d4fb7d5210a4ef4c89c"
  end

  depends_on "cmake" => :build
  depends_on "flatbuffers" => :build
  depends_on "nanobind" => :build
  depends_on "ninja" => :build
  depends_on "python@3.15" => [:build, :test]
  depends_on "lld"
  depends_on "llvm"
  depends_on "wabt" => :no_linkage

  deny_network_access!

  def install
    llvm = deps.map(&:name).find { |f| f.match?(/^llvm(@\d+(\.\d+)*)?$/) }
    site_packages = prefix/Language::Python.site_packages(python3)
    rpaths = [rpath, rpath(source: site_packages/"halide")]
    rpaths << formula_opt_lib(llvm).to_s if OS.linux?
    args = [
      "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
      "-DHalide_INSTALL_PYTHONDIR=#{site_packages}/halide",
      "-DHalide_LLVM_SHARED_LIBS=ON",
      "-DWITH_TESTS=OFF",
    ]
    args << "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-dead_strip_dylibs" if OS.mac?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    cp share/"doc/Halide/tutorial/lesson_01_basics.cpp", testpath
    system ENV.cxx, "-std=c++17", "lesson_01_basics.cpp", "-L#{lib}", "-lHalide", "-o", "test"
    assert_match "Success!", shell_output("./test")

    cp share/"doc/Halide_Python/tutorial-python/lesson_01_basics.py", testpath
    assert_match "Success!", shell_output("#{python3} lesson_01_basics.py")
  end
end
