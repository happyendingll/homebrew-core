class Imagesnap < Formula
  desc "Tool to capture still images from an iSight or other video source"
  homepage "https://github.com/rharder/imagesnap"
  url "https://github.com/rharder/imagesnap/archive/refs/tags/0.3.1.tar.gz"
  sha256 "47bea0dd3c9a3bb2d73e21ebde0eab9455232abf6fe0a8cd71742aa902f8a46e"
  license :public_domain

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "5d3ddacd5e693fc5d204604ac69a3f4deee47ef8bba2c0e529bef3cde069cbe9"
  end

  depends_on xcode: :build
  depends_on :macos

  def install
    xcodebuild "-arch", Hardware::CPU.arch, "-project", "ImageSnap.xcodeproj", "SYMROOT=build",
"MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"
    bin.install "build/Release/imagesnap"
  end

  test do
    assert_match "imagesnap", shell_output("#{bin}/imagesnap -h")
  end
end
