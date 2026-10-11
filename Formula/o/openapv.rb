class Openapv < Formula
  desc "Open Advanced Professional Video Codec"
  homepage "https://github.com/AcademySoftwareFoundation/openapv"
  url "https://github.com/AcademySoftwareFoundation/openapv/archive/refs/tags/v1.1.3.0.tar.gz"
  sha256 "38f841ce44e80c40b682a5323b4f3ebc6e339b6071965bc1c705a17d46ab2fc8"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "45e198cb3f13cf0b8ac4537aee2e5c557b2294631950649a61c03c9bbf94ee4a"
  end

  depends_on "cmake" => :build

  resource "homebrew-test_video", :test do
    url "https://raw.githubusercontent.com/fraunhoferhhi/vvenc/master/test/data/RTn23_80x44p15_f15.yuv"
    sha256 "ecd2ef466dd2975f4facc889e0ca128a6bea6645df61493a96d8e7763b6f3ae9"
  end

  allow_network_access! :test

  def install
    system "cmake", "-S", ".", "-B", "build",
           "-DOAPV_APP_STATIC_BUILD=OFF",
           "-DCMAKE_INSTALL_RPATH=#{rpath}",
           *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    resource("homebrew-test_video").stage testpath

    system bin/"oapv_app_enc", "-i", "RTn23_80x44p15_f15.yuv",
           "--input-csp", "2", "--width", "80", "--height", "44", "--fps", "15",
           "-o", "encoded.apv"
    assert_path_exists testpath/"encoded.apv"

    system bin/"oapv_app_dec", "-i", "encoded.apv", "-o", "decoded.y4m"
    assert_path_exists testpath/"decoded.y4m"
  end
end
