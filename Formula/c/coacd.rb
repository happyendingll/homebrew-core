class Coacd < Formula
  desc "Approximate convex decomposition for 3D meshes with collision-aware concavity"
  homepage "https://github.com/SarahWeiii/CoACD"
  url "https://github.com/SarahWeiii/CoACD/archive/refs/tags/1.0.14.tar.gz"
  sha256 "7a5d898c55a48668b19592a3bb8c5e3eb103836cda6883ca8955dfdce056d322"
  license "MIT"

  head "https://github.com/SarahWeiii/CoACD.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "7313146cd23956c6de1f74f25df1f3e75c4ea14ca029d945c68674d4e2d584e4"
  end

  depends_on "cmake" => :build

  resource "cdt" do
    url "https://github.com/artem-ogre/CDT.git",
        revision: "ec03b309fd18102ab1da069f2edf3b37be5d1fb3"
  end

  deny_network_access!

  def install
    resource("cdt").stage(buildpath/"3rd/cdt")

    args = %w[
      -DWITH_3RD_PARTY_LIBS=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <CoACD/coacd.h>
      #include <cassert>

      int main() {
        coacd::Mesh input;
        input.vertices = {{0.0, 0.0, 0.0}, {1.0, 0.0, 0.0}, {0.0, 1.0, 0.0}, {0.0, 0.0, 1.0}};
        input.indices  = {{0, 1, 2}, {0, 2, 3}, {0, 3, 1}, {1, 3, 2}};
        auto result = coacd::CoACD(input, 0.5, -1, "off", 50, 2000, 20, 100, 3, false, false);
        assert(!result.empty());
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++20", "test.cpp", "-I#{include}", "-L#{lib}", "-o", "test", "-l_coacd"
    system "./test"
  end
end
