class MediaControl < Formula
  desc "Control and observe media playback from the command-line"
  homepage "https://github.com/ungive/media-control"
  url "https://github.com/ungive/media-control.git",
      tag:      "v0.8.0",
      revision: "e711d3ffbdc97add23cf0133d073a1ae773348b2"
  license "BSD-3-Clause"
  head "https://github.com/ungive/media-control.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "1b8bfd072868eed4b639759f167e12d945f4f4329102019a1527ca0c33e82e45"
  end

  depends_on "cmake" => :build
  depends_on :macos

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/media-control version")
    # `test` needs `mediaremoted`, which the `brew test` sandbox blocks, so only check the framework loads
    assert_equal "null", shell_output("#{bin}/media-control get").chomp
  end
end
