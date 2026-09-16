class MediaControl < Formula
  desc "Control and observe media playback from the command-line"
  homepage "https://github.com/ungive/media-control"
  url "https://github.com/ungive/media-control.git",
      tag:      "v0.7.7",
      revision: "3cfd5dcf78e7a619f7a42a3e2f29b06eb41027ea"
  license "BSD-3-Clause"
  head "https://github.com/ungive/media-control.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "41df54fef35ae08a627f41797966bab7353020de85bfc6b54076e497bb40845a"
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
