class Halide < Formula
  desc "Language for fast, portable data-parallel computation"
  homepage "https://halide-lang.org"
  url "https://github.com/halide/Halide/archive/refs/tags/v22.0.0.post1.tar.gz"
  version "22.0.0"
  sha256 "0f219a9b2cb0f0dcffcaded095587c5c495ea2ea663fc92b18157500a9f2c4ba"
  license "MIT"
  head "https://github.com/halide/Halide.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "a92b759bc40b812bdd9c2629d224c2803a47c12fa2138639898030aa875ca0b5"
  end

  depends_on "cmake" => :build
  depends_on "flatbuffers" => :build
  depends_on "ninja" => :build
  depends_on "python@3.15" => [:build, :test]
  depends_on "robin-map" => :build # for nanobind
  depends_on "lld"
  depends_on "llvm"
  depends_on "wabt" => :no_linkage

  # Need nanobind < 2.12
  resource "nanobind" do
    url "https://github.com/wjakob/nanobind/archive/refs/tags/v2.11.0.tar.gz"
    sha256 "62ba05e5f720c76c510d6ab2a77f8ccc17a76c5cea951bea47355a7dfa460449"
  end

  deny_network_access!

  def install
    resource("nanobind").stage do
      system "cmake", "-S", ".", "-B", "build",
                      "-DNB_TEST=OFF",
                      "-DNB_USE_SUBMODULE_DEPS=OFF",
                      "-DNB_CREATE_INSTALL_RULES=ON",
                      *std_cmake_args(install_prefix: buildpath)
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
      ENV.prepend_path "CMAKE_PREFIX_PATH", buildpath/"nanobind"
    end

    llvm = deps.map(&:name).find { |f| f.match?(/^llvm(@\d+(\.\d+)*)?$/) }
    site_packages = prefix/Language::Python.site_packages(python3)
    rpaths = [rpath, rpath(source: site_packages/"halide")]
    rpaths << formula_opt_lib(llvm).to_s if OS.linux?
    args = [
      "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
      "-DHalide_INSTALL_PYTHONDIR=#{site_packages}/halide",
      "-DHalide_LLVM_SHARED_LIBS=ON",
      "-DWITH_TESTS=NO",
    ]
    args << "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-dead_strip_dylibs" if OS.mac?

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *args, *std_cmake_args
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
