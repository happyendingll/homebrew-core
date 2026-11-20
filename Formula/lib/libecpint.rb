class Libecpint < Formula
  desc "Library for the efficient evaluation of integrals over effective core potentials"
  homepage "https://github.com/robashaw/libecpint"
  url "https://github.com/robashaw/libecpint/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "080e3176c7fb6d761f14ae585022e1fd070c26c70ec9e38641b6f17608cb09d0"
  license "MIT"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "68aabdc5cccf08890f25a85e972fe89c31c73bd35428953c2de9267a7cb46d6e"
  end

  depends_on "cmake" => :build
  depends_on "libcerf"
  depends_on "pugixml"

  uses_from_macos "python" => :build

  deny_network_access!

  def install
    args = [
      "-DBUILD_SHARED_LIBS=ON",
      "-DLIBECPINT_USE_CERF=ON",
      "-DLIBECPINT_BUILD_TESTS=OFF",
      "-DPython_EXECUTABLE=#{which("python3")}",
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    (pkgshare/"example").install "example/example.cpp", "example/hydrogen.bas", "example/iodine.bas"
  end

  test do
    cp pkgshare.glob("example/*"), testpath
    system ENV.cxx, "-std=c++17", "example.cpp", "-I#{include}", "-L#{lib}", "-lecpint", "-o", "example"
    output = shell_output("./example #{pkgshare}")
    assert_match "Basis read: 44, 12, 36", output
    assert_match "Done.", output
  end
end
