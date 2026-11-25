class MediaControl < Formula
  desc "Control and observe media playback from the command-line"
  homepage "https://github.com/ungive/media-control"
  url "https://github.com/ungive/media-control.git",
      tag:      "v0.9.0",
      revision: "507575ce288a9238372b7f39fde44988612700d4"
  license "BSD-3-Clause"
  head "https://github.com/ungive/media-control.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "6506ee57f903a1f701862fe03b94ecdbc55f441f0671455da5517db1a6a020f8"
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
