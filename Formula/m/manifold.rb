class Manifold < Formula
  desc "Geometry library for topological robustness"
  homepage "https://github.com/elalish/manifold"
  url "https://github.com/elalish/manifold/releases/download/v3.5.4/manifold-3.5.4.tar.gz"
  sha256 "db2a8e7aac6abac12fe54fa7b055d24741362b5706fee6f5c5b8f0bccd2de4ec"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "00c1dae00e425a4ddde193b2812873060c9cbe3378c24b21e58b9cae769ec2d7"
  end

  depends_on "cmake" => :build
  depends_on "clipper2"
  depends_on "tbb"

  deny_network_access!

  def install
    args = %w[
      -DMANIFOLD_DOWNLOADS=OFF
      -DMANIFOLD_PAR=ON
      -DMANIFOLD_TEST=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "extras/large_scene_test.cpp"
  end

  test do
    system ENV.cxx, pkgshare/"large_scene_test.cpp",
                    "-std=c++17", "-I#{include}", "-L#{lib}", "-lmanifold",
                    "-o", "test"
    assert_match "nTri = 91814", shell_output("./test")
  end
end
