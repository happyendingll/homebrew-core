class Iir1 < Formula
  desc "DSP IIR realtime filter library written in C++"
  homepage "https://berndporr.github.io/iir1/"
  url "https://github.com/berndporr/iir1/archive/refs/tags/1.11.1.tar.gz"
  sha256 "ee3ffd1c8b7d406cd5610d537a9e033d93e00f5db208ea0341f0dbd0472e486a"
  license "MIT"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "68d53cf256c1b98d73b85adeaceb5094fe9da74e80532ad680eb50490c85f357"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    (pkgshare/"test").install "test/assert_print.h", "test/butterworth.cpp", "test/scipy.cpp",
                              "test/scipy.h", "test/signal.csv", *Dir["test/butterworth-*.csv"]
  end

  test do
    cp (pkgshare/"test").children, testpath
    system ENV.cxx, "-std=c++11", "butterworth.cpp", "scipy.cpp", "-o", "test", "-L#{lib}", "-liir"
    system "./test"
  end
end
