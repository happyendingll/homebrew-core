class Ffms2 < Formula
  desc "Libav/ffmpeg based source library and Avisynth plugin"
  homepage "https://github.com/FFMS/ffms2"
  url "https://github.com/FFMS/ffms2/archive/refs/tags/5.0.tar.gz"
  sha256 "7770af0bbc0063f9580a6a5c8e7c51f1788f171d7da0b352e48a1e60943a8c3c"
  # The FFMS2 source is licensed under the MIT license, but its binaries
  # are licensed under the GPL because GPL components of FFmpeg are used.
  license "GPL-2.0-or-later"
  revision 6
  compatibility_version 1
  head "https://github.com/FFMS/ffms2.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "2863f57a0e82a95001e0346a7cd9eff779cee2ba6840d44759424243ab44462d"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.15" => [:build, :test]
  depends_on "vapoursynth" => :test
  depends_on "ffmpeg"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  resource "homebrew-videosample", :test do
    url "https://samples.mplayerhq.hu/V-codecs/lm20.avi"
    sha256 "a0ab512c66d276fd3932aacdd6073f9734c7e246c8747c48bf5d9dd34ac8b392"
  end

  def install
    system "./autogen.sh", "--enable-avresample", *std_configure_args
    system "make", "install"

    vapoursynth_plugins = prefix/Language::Python.site_packages(python3)/"vapoursynth/plugins"
    vapoursynth_plugins.install_symlink lib/shared_library("libffms2")
  end

  test do
    # download small sample and check that the index was created
    resource("homebrew-videosample").stage do
      system bin/"ffmsindex", "lm20.avi"
      assert_path_exists Pathname.pwd/"lm20.avi.ffindex"
    end

    # Test VapourSynth support which verifies Python versions are aligned
    cp test_fixtures("test.mp4"), testpath
    system python3, "-c", "from vapoursynth import core; core.ffms2.Source('test.mp4')"
    assert_path_exists "test.mp4.ffindex"
  end
end
