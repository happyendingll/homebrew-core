class TerminalNotifier < Formula
  desc "Send macOS User Notifications from the command-line"
  homepage "https://github.com/julienXX/terminal-notifier"
  url "https://github.com/julienXX/terminal-notifier/archive/refs/tags/3.1.0.tar.gz"
  sha256 "7dac44a563f00c10d49aa2da4cde9d1fecdb12b36ed57fe7fdff789c3578421e"
  license "MIT"
  head "https://github.com/julienXX/terminal-notifier.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "5cf50ca94491169323dbc1fd92103a3512f1ead5622cb21fca6b42c3addd46a9"
  end

  depends_on xcode: :build
  depends_on :macos

  def install
    xcodebuild "-arch", Hardware::CPU.arch,
               "-project", "Terminal Notifier.xcodeproj",
               "-target", "terminal-notifier",
               "SYMROOT=build",
               "-verbose",
               "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"
    prefix.install "build/Release/terminal-notifier.app"
    bin.write_exec_script prefix/"terminal-notifier.app/Contents/MacOS/terminal-notifier"
  end

  test do
    assert_match version.to_s, pipe_output("#{bin}/terminal-notifier -help")

    # check the signature and not just the help output.
    app = prefix/"terminal-notifier.app"
    system "/usr/bin/codesign", "--verify", "--strict", app
    assert_match "fr.julienxx.oss.terminal-notifier",
                 shell_output("/usr/bin/codesign -dv #{app} 2>&1")
  end
end
