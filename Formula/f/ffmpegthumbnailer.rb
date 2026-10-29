class Ffmpegthumbnailer < Formula
  desc "Create thumbnails for your video files"
  homepage "https://github.com/dirkvdb/ffmpegthumbnailer"
  url "https://github.com/dirkvdb/ffmpegthumbnailer/archive/refs/tags/v2.4.0.tar.gz"
  sha256 "0f2ed039b7f495da217e266a509108e914156ef0e321b49342ebb37b345ccec6"
  license "GPL-2.0-or-later"
  compatibility_version 1
  head "https://github.com/dirkvdb/ffmpegthumbnailer.git", branch: "master"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "ed1dfa202553d02e4725c73f39943a8d31588024c32bae86ded123c3e763cbfe"
    sha256 cellar: :any, arm64_tahoe:       "e6fb754b04946426830ad3b6f75a19e197e01c512ca440904d4d1dfeb6b852a4"
    sha256 cellar: :any, arm64_sequoia:     "f4a27514b90c933bff1ebfb2bebe39129d8e0acccc715c25b4143b6497ba2458"
    sha256 cellar: :any, arm64_linux:       "8c5e09a4f51e223fac402580e5b5367fb28106eda87a2a71e0c6b397b0f39dcf"
    sha256 cellar: :any, x86_64_linux:      "b5b3af4a888248c20f423018c45833ba1782a8ed234df12a4f83a7d7c0df6708"
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
