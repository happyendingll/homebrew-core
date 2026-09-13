class Blueutil < Formula
  desc "Get/set bluetooth power and discoverable state"
  homepage "https://github.com/toy/blueutil"
  url "https://github.com/toy/blueutil/archive/refs/tags/v2.14.0.tar.gz"
  sha256 "8749883d52be4630c0b557656a487432050cc6e5d125f60d5b1efe646797d152"
  license "MIT"
  head "https://github.com/toy/blueutil.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "390b74c05782121a9f0d671763c8289bc5f7cd4939a7872c2712500ad297c102"
  end

  depends_on xcode: :build
  depends_on :macos

  def install
    # Set to build with SDK=macosx10.6, but it doesn't actually need 10.6
    xcodebuild "-arch", Hardware::CPU.arch,
               "SDKROOT=",
               "SYMROOT=build",
               "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"
    bin.install "build/Release/blueutil"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/blueutil --version")
    # We cannot test any useful command since Sonoma as OS privacy restrictions
    # will wait until Bluetooth permission is either accepted or rejected.
    system bin/"blueutil", "--discoverable", "0" if MacOS.version < :sonoma
  end
end
