class IosDeploy < Formula
  desc "Install and debug iPhone apps from the command-line"
  homepage "https://github.com/ios-control/ios-deploy"
  url "https://github.com/ios-control/ios-deploy/archive/refs/tags/1.12.2.tar.gz"
  sha256 "2a1e9836192967f60194334261e7af4de2ba72e4047a3e54376e5caa57a1db70"
  license all_of: ["GPL-3.0-or-later", "BSD-3-Clause"]
  head "https://github.com/ios-control/ios-deploy.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "34fbe3cde8956a608bc2e62719c7a1860e99a013fb7a5ff7df18b225632dd287"
  end

  depends_on xcode: :build
  depends_on :macos

  def install
    xcodebuild "-configuration", "Release",
               "SYMROOT=build",
               "-arch", Hardware::CPU.arch,
               "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"

    bin.install "build/Release/ios-deploy"
  end

  test do
    system bin/"ios-deploy", "-V"
  end
end
