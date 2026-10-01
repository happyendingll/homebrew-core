class Halide < Formula
  desc "Language for fast, portable data-parallel computation"
  homepage "https://halide-lang.org"
  license "MIT"
  revision 2
  head "https://github.com/halide/Halide.git", branch: "main"

  stable do
    url "https://github.com/halide/Halide/archive/refs/tags/v21.0.0.tar.gz"
    sha256 "aa6b6f5e89709ca6bc754ce72b8b13b2abce0d6b001cb2516b1c6f518f910141"

    # Backport support for wabt 1.0.39
    patch do
      url "https://github.com/halide/Halide/commit/7d7f0b4422594296fed1d561a43dc262d163d2b8.patch?full_index=1"
      sha256 "6b861e585ce4d71aec53b225562e078086ee310e8c6e7a052bf3fd53f03322ab"
      type :backport
      resolves "https://github.com/halide/Halide/pull/8923"
    end

    # Backport dropping the exact wabt version to build with wabt 1.0.41
    patch do
      url "https://github.com/halide/Halide/commit/6a7ed977f0e03dc812b8ae4ef43654178d651c46.patch?full_index=1"
      sha256 "63232c844394cbaff3137f2a9e144579d4ad0af150ed1cf0e784edcc3d07b503"
      type :backport
      resolves "https://github.com/halide/Halide/pull/9016"
    end

    # Backport support for wabt 1.0.42
    patch do
      url "https://github.com/halide/Halide/commit/038f2e8a2824ec69db8f7785bf963b0ff110df2f.patch?full_index=1"
      sha256 "4179d05badd64af26a82fe38d2146bdbb2eb36d54a0fc7c9ccb30364813d69da"
      type :backport
      resolves "https://github.com/halide/Halide/pull/9473"
    end
  end

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "3005393a306833d0550624f0fbdc913c54b6fc93f37d3634757f9f43a36fae5f"
  end

  depends_on "cmake" => :build
  depends_on "flatbuffers" => :build
  depends_on "pybind11" => :build
  depends_on "python@3.14" => [:build, :test]
  depends_on "lld@21"
  depends_on "llvm@21"
  depends_on "wabt" => :no_linkage

  deny_network_access!

  def install
    # Disable SVE feature as broken: https://github.com/halide/Halide/issues/8529
    inreplace "src/Target.cpp", /^\s*initial_features.push_back\(Target::SVE/, "// \\0"

    llvm = deps.map(&:to_formula).find { |f| f.name.match?(/^llvm(@\d+(\.\d+)*)?$/) }
    site_packages = prefix/Language::Python.site_packages(python3)
    rpaths = [rpath, rpath(source: site_packages/"halide")]
    rpaths << llvm.opt_lib.to_s if OS.linux?
    args = [
      "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
      "-DHalide_INSTALL_PYTHONDIR=#{site_packages}/halide",
      "-DHalide_LLVM_SHARED_LIBS=ON",
      "-DHalide_USE_FETCHCONTENT=OFF",
      "-DWITH_TESTS=NO",
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
