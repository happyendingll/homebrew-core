class Mgis < Formula
  desc "Provide tools to handle MFront generic interface behaviours"
  homepage "https://thelfer.github.io/mgis/web/index.html"
  url "https://github.com/thelfer/MFrontGenericInterfaceSupport/archive/refs/tags/MFrontGenericInterfaceSupport-3.1.tar.gz"
  sha256 "61afae1a367dbb150b24ca85f042efb15a77184a54a746f11c08d9b7cb9e94f3"
  license any_of: ["LGPL-3.0-only", "CECILL-1.0"]
  head "https://github.com/thelfer/MFrontGenericInterfaceSupport.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "11bcb16a70f652cfd572b6879962d23378fae558c98ef9eff48c65322b4e05e0"
  end

  depends_on "cmake" => :build
  depends_on "pybind11" => :build

  depends_on "gcc" # for gfortran
  depends_on "numpy"
  depends_on "python@3.15"
  depends_on "tbb"

  def install
    args = [
      "-Denable-portable-build=ON",
      "-Denable-website=OFF",
      "-Denable-enable-doxygen-doc=OFF",
      "-Denable-c-bindings=ON",
      "-Denable-fortran-bindings=ON",
      "-Denable-python-bindings=ON",
      "-Denable-pybind11=ON",         # requires pybind11
      "-Denable-fenics-bindings=OFF", # experimental and very limited
      "-Denable-julia-bindings=OFF",  # requires CxxWrap library
      "-Denable-enable-static=OFF",
      "-Ddisable_python_library_linking=ON",
      "-DCMAKE_INSTALL_RPATH=#{rpath}",
      "-DPython_ADDITIONAL_VERSIONS=#{Language::Python.major_minor_version python3}",
    ]

    if OS.mac?
      # Use -dead_strip_dylibs to avoid linkage to boost container and graph modules
      # Issue ref: https://github.com/boostorg/boost/issues/985
      linker_flags = %W[
        -Wl,-dead_strip_dylibs
        -Wl,-rpath,#{rpath(source: prefix/Language::Python.site_packages(python3)/"mgis")}
      ]
      args << "-DCMAKE_MODULE_LINKER_FLAGS=#{linker_flags.join(" ")}"
    end

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system python3, "-c", "import mgis.behaviour"
    system python3, "-c", "import mgis.model"
  end
end
