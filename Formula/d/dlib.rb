class Dlib < Formula
  desc "C++ library for machine learning"
  homepage "https://dlib.net/"
  url "https://github.com/davisking/dlib/archive/refs/tags/v20.1.tar.gz"
  sha256 "fbbc5f5819c598c54cc682b78813226467f36c0c0ffa19ad527412d87970fdb8"
  license "BSL-1.0"
  compatibility_version 1
  head "https://github.com/davisking/dlib.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "260791195cd67f9d4589415c91e136643aa112c2a5a58b1dc8349f73cfbe716f"
  end

  depends_on "cmake" => :build
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "openblas"

  deny_network_access!

  def install
    args = %W[
      -DDLIB_USE_BLAS=ON
      -DDLIB_USE_LAPACK=ON
      -Dcblas_lib=#{formula_opt_lib("openblas")/shared_library("libopenblas")}
      -Dlapack_lib=#{formula_opt_lib("openblas")/shared_library("libopenblas")}
      -DDLIB_NO_GUI_SUPPORT=ON
      -DDLIB_LINK_WITH_SQLITE3=OFF
      -DBUILD_SHARED_LIBS=ON
    ]
    args << "-DUSE_SSE2_INSTRUCTIONS=ON" if Hardware::CPU.intel?

    system "cmake", "-S", "dlib", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <dlib/logger.h>
      dlib::logger dlog("example");
      int main() {
        dlog.set_level(dlib::LALL);
        dlog << dlib::LINFO << "The answer is " << 42;
      }
    CPP
    system ENV.cxx, "-pthread", "-std=c++17", "test.cpp", "-o", "test", "-I#{include}",
                    "-L#{lib}", "-ldlib"
    assert_match(/INFO.*example: The answer is 42/, shell_output("./test"))
  end
end
