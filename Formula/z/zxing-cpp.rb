class ZxingCpp < Formula
  desc "Multi-format barcode image processing library written in C++"
  homepage "https://github.com/zxing-cpp/zxing-cpp"
  url "https://github.com/zxing-cpp/zxing-cpp/releases/download/v3.2.0/zxing-cpp-3.2.0.tar.gz"
  sha256 "eacc2495f452be751d9dd453f4d6cccd0e9a40131e002bcf54d2580ce5c19ad8"
  license "Apache-2.0"
  head "https://github.com/zxing-cpp/zxing-cpp.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "d47d6941b8506049b434f95c02c4e4cd5c8d120e916f27a3ae605928b2998fac"
  end

  depends_on "cmake" => :build

  resource "stb_image" do
    url "https://raw.githubusercontent.com/nothings/stb/013ac3beddff3dbffafd5177e7972067cd2b5083/stb_image.h"
    version "2.30"
    sha256 "594c2fe35d49488b4382dbfaec8f98366defca819d916ac95becf3e75f4200b3"
  end

  resource "stb_image_write" do
    url "https://raw.githubusercontent.com/nothings/stb/1ee679ca2ef753a528db5ba6801e1067b40481b8/stb_image_write.h"
    version "1.16"
    sha256 "cbd5f0ad7a9cf4468affb36354a1d2338034f2c12473cf1a8e32053cb6914a05"
  end

  deny_network_access!

  def install
    resources.each do |r|
      r.stage do
        (include/"stb").install "#{r.name}.h"
      end
    end

    args = %W[
      -DZXING_DEPENDENCIES=LOCAL
      -DSTB_IMAGE_INCLUDE_DIR=#{include}/stb
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <ZXing/ZXingCpp.h>
      int main() {
        ZXing::ReaderOptions options;
        (void)options;
        return 0;
      }
    CPP

    system ENV.cxx, "test.cpp", "-std=c++20", "-I#{include}", "-L#{lib}", "-lZXing", "-o", "test"
    system "./test"

    assert_match version.to_s, shell_output("#{bin}/ZXingReader --version")
  end
end
