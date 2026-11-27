class Libcue < Formula
  desc "Cue sheet parser library for C"
  homepage "https://github.com/lipnitsk/libcue"
  url "https://github.com/lipnitsk/libcue/archive/refs/tags/v2.4.4.tar.gz"
  sha256 "d972a35ef525c2d8aacc6d8dd47ac9379d9abf8166cdae93b2e385f287476918"
  license "GPL-2.0-only"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "4202ff632e2c8929f3470f2ca42592d3510cd767a04cfb1020c3db23d702d51c"
  end

  depends_on "bison" => :build # Needs bison 2.4+
  depends_on "cmake" => :build

  uses_from_macos "flex" => :build

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", "-DBUILD_SHARED_LIBS=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    (pkgshare/"tests").install Dir["t/*"]
  end

  test do
    cp_r (pkgshare/"tests").children, testpath
    Dir["*.c"].each do |f|
      system ENV.cc, f, "-o", "test", "-L#{lib}", "-lcue", "-I#{include}"
      system "./test"
      rm "test"
    end
  end
end
