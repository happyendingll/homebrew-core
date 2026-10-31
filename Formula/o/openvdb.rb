class Openvdb < Formula
  desc "Sparse volumetric data processing toolkit"
  homepage "https://www.openvdb.org/"
  url "https://github.com/AcademySoftwareFoundation/openvdb/archive/refs/tags/v14.0.0.tar.gz"
  sha256 "2c38592a42a9dc1f3e9749418cc9d286d88ed912232dafee954ce5156174e5b0"
  license "MPL-2.0"
  head "https://github.com/AcademySoftwareFoundation/openvdb.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "5d3fcd4e03afd0c1f186dd98bf112dfa462c0ee20360f0d116fee0a1dbd1e235"
  end

  depends_on "cmake" => :build

  depends_on "jemalloc"
  depends_on "tbb"
  depends_on "zstd"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  resource "homebrew-test_file", :test do
    url "https://artifacts.aswf.io/io/aswf/openvdb/models/cube.vdb/1.0.0/cube.vdb-1.0.0.zip"
    sha256 "05476e84e91c0214ad7593850e6e7c28f777aa4ff0a1d88d91168a7dd050f922"
  end

  allow_network_access! :test

  def install
    args = [
      "-DDISABLE_DEPENDENCY_VERSION_CHECKS=ON",
      "-DUSE_NANOVDB=ON",
      "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath,#{rpath}",
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    testpath.install resource("homebrew-test_file")
    system bin/"vdb_print", "-m", "cube.vdb"
  end
end
