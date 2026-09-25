class Ctl < Formula
  desc "Programming language for digital color management"
  homepage "https://github.com/aces-aswf/CTL"
  url "https://github.com/aces-aswf/CTL/archive/refs/tags/ctl-1.5.5.tar.gz"
  sha256 "b6a36ac31e0a79224216e4fc41b56982939cec7a1afd4e80165cec3f1c37d265"
  license "AMPAS"
  revision 1
  head "https://github.com/aces-aswf/CTL.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "6fd76504f0d5779b8ee9b1a76784e81fde94e792f0efd6fabf928370abb4b7f1"
  end

  depends_on "cmake" => :build
  depends_on "imath"
  depends_on "libtiff"
  depends_on "openexr"

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_SHARED_LIBS=ON",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}",
                    "-DCTL_BUILD_TESTS=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match "transforms an image", shell_output("#{bin}/ctlrender -help", 1)
  end
end
