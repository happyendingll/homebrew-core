class Rsgain < Formula
  desc "ReplayGain 2.0 tagging utility"
  homepage "https://github.com/complexlogic/rsgain"
  url "https://github.com/complexlogic/rsgain/archive/refs/tags/v3.8.tar.gz"
  sha256 "6fb484d9af613167d54fbea60ae647ac1e7baa28b3a9ee4fdfe421601878dfea"
  license "BSD-2-Clause"
  head "https://github.com/complexlogic/rsgain.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 sequoia: "48b65132beff1b4b8f3704975cd9b68edb4366d77ad4fa29f9c73b0deb3f81db"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "ffmpeg"
  depends_on "fmt"
  depends_on "inih"
  depends_on "libebur128"
  depends_on "taglib"

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rsgain -v")

    assert_match "No files were scanned",
      shell_output("#{bin}/rsgain easy -S #{testpath}")
  end
end
