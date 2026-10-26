class Apngasm < Formula
  desc "Next generation of apngasm, the APNG assembler"
  homepage "https://github.com/apngasm/apngasm"
  url "https://github.com/apngasm/apngasm/archive/refs/tags/3.1.10.tar.gz"
  sha256 "8171e2c1d37ab231a2061320cb1e5d15cee37642e3ce78e8ab0b8dfc45b80f6c"
  license "Zlib"
  revision 22
  head "https://github.com/apngasm/apngasm.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "942a5f9c83aee8e3280974a3d6267bc6a5c4ebe9d33fa13907e8f2dcb735832a"
  end

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "icu4c@79"
  depends_on "libpng"
  depends_on "lzlib"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  fails_with :gcc do
    version "7"
    cause "Requires C++17 filesystem"
  end

  # Fix build with Boost 1.89.0, pr ref: https://github.com/apngasm/apngasm/pull/111
  patch do
    url "https://github.com/apngasm/apngasm/commit/7bf77bdefd348c629f650e2a5102a26ab6bee7b8.patch?full_index=1"
    sha256 "cbb9d679c5d46424bb00962481903f12b8b0e943dfdc98910ad05af7c7dacf5b"
    type :unofficial
    resolves "https://github.com/apngasm/apngasm/pull/111"
  end

  deny_network_access!

  def install
    inreplace "cli/CMakeLists.txt", "${CMAKE_INSTALL_PREFIX}/man/man1",
                                    "${CMAKE_INSTALL_PREFIX}/share/man/man1"
    ENV.deparallelize # Build error: ld: library not found for -lapngasm

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, "-DCMAKE_INSTALL_RPATH=#{rpath}"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    (pkgshare/"test").install "test/samples"
  end

  test do
    system bin/"apngasm", pkgshare/"test/samples/clock*.png"
  end
end
