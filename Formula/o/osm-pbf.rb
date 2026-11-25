class OsmPbf < Formula
  desc "Tools related to PBF (an alternative to XML format)"
  homepage "https://wiki.openstreetmap.org/wiki/PBF_Format"
  url "https://github.com/openstreetmap/OSM-binary/archive/refs/tags/v1.8.0.tar.gz"
  sha256 "18ec63e28a42073db62e8fb59134b8bd410c29e8eb1d8ec1759efc9501fbf41a"
  license "LGPL-3.0-or-later"
  revision 2

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "3f011eec8dbfffafeb95cb2b9d84c99cc516af3b5f20d2abebafef7e4cda70d3"
  end

  depends_on "cmake" => :build
  depends_on "protobuf"

  deny_network_access!

  def install
    args = ["-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-dead_strip_dylibs"] if OS.mac?
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    pkgshare.install "resources/sample.pbf"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <iostream>
      #include <osmpbf/osmpbf.h>

      int main() {
        OSMPBF::BlobHeader header;
        header.set_type("OSMHeader");
        std::cout << header.type() << std::endl;
        return 0;
      }
    CPP

    system ENV.cxx, testpath/"test.cpp",
           "-std=c++17",
           "-I#{include}",
           "-I#{formula_opt_include("protobuf")}",
           "-I#{formula_opt_include("abseil")}",
           "-L#{lib}",
           "-L#{formula_opt_lib("protobuf")}",
           "-L#{formula_opt_lib("abseil")}",
           "-losmpbf",
           "-lprotobuf",
           "-labsl_log_internal_check_op",
           "-labsl_log_internal_message",
           "-o", testpath/"test"

    assert_equal "OSMHeader", shell_output(testpath/"test").chomp
  end
end
