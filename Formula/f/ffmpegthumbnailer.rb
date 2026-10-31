class Ffmpegthumbnailer < Formula
  desc "Create thumbnails for your video files"
  homepage "https://github.com/dirkvdb/ffmpegthumbnailer"
  url "https://github.com/dirkvdb/ffmpegthumbnailer/archive/refs/tags/v2.4.1.tar.gz"
  sha256 "779ff290a2b874fc889b28aa4c89fb5d1dbc9a15ee1d09524ed346bd83a4d920"
  license "GPL-2.0-or-later"
  compatibility_version 1
  head "https://github.com/dirkvdb/ffmpegthumbnailer.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "627ddcce416d0f96f63802f0e6f0eb528a809cbaba002c94dc90cc87f61bbbf1"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "ffmpeg"
  depends_on "jpeg-turbo"
  depends_on "libpng"

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}",
                    "-DENABLE_GIO=ON",
                    "-DENABLE_TESTS=OFF",
                    "-DENABLE_THUMBNAILER=ON",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    ffmpeg = formula_opt_bin("ffmpeg")/"ffmpeg"
    png = test_fixtures("test.png")
    system ffmpeg.to_s, "-loop", "1", "-i", png.to_s, "-c:v", "libx264", "-t", "30",
                        "-pix_fmt", "yuv420p", "v.mp4"
    assert_path_exists testpath/"v.mp4", "Failed to generate source video!"
    system bin/"ffmpegthumbnailer", "-i", "v.mp4", "-o", "out.jpg"
    assert_path_exists testpath/"out.jpg", "Failed to create thumbnail!"
  end
end
