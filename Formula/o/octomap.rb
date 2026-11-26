class Octomap < Formula
  desc "Efficient probabilistic 3D mapping framework based on octrees"
  homepage "https://octomap.github.io/"
  url "https://github.com/OctoMap/octomap/archive/refs/tags/v2.0.1.tar.gz"
  sha256 "b3bbadf9ee9f05792d08f626dd0e784489fdad662eb2fbf311683241706bf60f"
  license "BSD-3-Clause"
  compatibility_version 2

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "ae061f3703e6a96f01da7103a780f29b58a98c22fb82cb9f34bfe4824ac0b57d"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :test

  deny_network_access!

  def install
    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]

    system "cmake", "-S", "octomap", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <cassert>
      #include <octomap/octomap.h>
      int main() {
        octomap::OcTree tree(0.05);
        assert(tree.size() == 0);
        return 0;
      }
    CPP

    flags = shell_output("pkgconf --cflags --libs octomap").chomp.split
    system ENV.cxx, "test.cpp", "-o", "test", *flags
    system "./test"
  end
end
