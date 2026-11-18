class Systemc < Formula
  desc "Core SystemC language and examples"
  homepage "https://systemc.org/overview/systemc/"
  url "https://github.com/accellera-official/systemc/archive/refs/tags/3.0.3.tar.gz"
  sha256 "6b4906fe564c81941b5d57c75ee9b20c44c3f4ead1cf607f38ff7beea9aacce4"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "2a9e5c9eadeb0d33a5075eaef8b455f901ab5a4a7c494fe624f15c77e156302f"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include "systemc.h"

      int sc_main(int argc, char *argv[]) {
        return 0;
      }
    CPP
    system ENV.cxx, "-std=gnu++17", "-L#{lib}", "-lsystemc", "test.cpp"
    system "./a.out"
  end
end
