class VideoCompare < Formula
  desc "Split screen video comparison tool using FFmpeg and SDL2"
  homepage "https://github.com/pixop/video-compare"
  url "https://github.com/pixop/video-compare/archive/refs/tags/20261123.tar.gz"
  sha256 "4318bc4778697ab8d6aaafbee234f537eeec897bccc583297435200efa00a027"
  license "GPL-2.0-only"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "18abc52772d9be8c8d9c70c533112006236dce8604e66f97ecd5b6659b9871ce"
  end

  depends_on "ffmpeg"
  depends_on "sdl2-compat"
  depends_on "sdl2_ttf"

  deny_network_access!

  def install
    system "make"
    bin.install "video-compare"
  end

  test do
    testvideo = test_fixtures("test.gif") # GIF is valid ffmpeg input format
    with_test_process(bin/"video-compare", testvideo, testvideo) do
      sleep 3
    end
  end
end
