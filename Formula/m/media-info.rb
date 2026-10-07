class MediaInfo < Formula
  desc "Unified display of technical and tag data for audio/video"
  homepage "https://mediaarea.net/"
  url "https://mediaarea.net/download/source/mediainfo/26.10/mediainfo_26.10.tar.xz"
  sha256 "82f6bce8e58818509022f0bbcc87fce0c6da21822fb2a2a9573b5e3950d8e5f6"
  license "BSD-2-Clause"
  compatibility_version 1
  head "https://github.com/MediaArea/MediaInfo.git", branch: "master"

  livecheck do
    url "https://mediaarea.net/en/MediaInfo/Download/Source"
    regex(/href=.*?mediainfo[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "686647a812c79453ac8b50c09124a6887840642e7c76a26afc9d51e797614890"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "libmediainfo"
  depends_on "libzen"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    cd "Project/GNU/CLI" do
      system "autoreconf", "--force", "--install", "--verbose"
      system "./configure", *std_configure_args
      system "make", "install"
    end
  end

  test do
    output = shell_output("#{bin}/mediainfo #{test_fixtures("test.mp3")}")
    assert_match <<~EOS, output
      General
      Complete name                            : #{test_fixtures("test.mp3")}
      Format                                   : MPEG Audio
    EOS

    assert_match version.to_s, shell_output("#{bin}/mediainfo --Version")
  end
end
