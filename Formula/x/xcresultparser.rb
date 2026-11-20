class Xcresultparser < Formula
  desc "Parse binary .xcresult bundles from Xcode builds and test runs"
  homepage "https://github.com/a7ex/xcresultparser"
  url "https://github.com/a7ex/xcresultparser/archive/refs/tags/2.3.0.tar.gz"
  sha256 "2ee9d6af50c7c9a06b7c444e8384998100b22eeb0f86424055caf26859bdb25d"
  license "MIT"
  head "https://github.com/a7ex/xcresultparser.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "5387f63a0641386c07b0650b8b9769d3fdbb07025e47c51f47d74bd2c9685b37"
  end

  depends_on xcode: ["15.0", :build]
  depends_on :macos

  deny_network_access!

  def fetch
    # SwiftPM tries to apply its own sandbox, which cannot nest inside the
    # build sandbox; Homebrew's sandbox still confines the whole process.
    system "swift", "package", "resolve", "--disable-sandbox"
  end

  def install
    system "swift", "build", *std_swift_args
    bin.install ".build/release/xcresultparser"
    pkgshare.install "Tests/XcresultparserTests/TestAssets/test.xcresult"
    generate_completions_from_executable(bin/"xcresultparser", "--generate-completion-script")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/xcresultparser -v")

    cp_r pkgshare/"test.xcresult", testpath
    output = shell_output("#{bin}/xcresultparser --target-info #{testpath}/test.xcresult")
    assert_match "XcresultparserLib", output
    assert_match "XcresultparserTests", output
  end
end
