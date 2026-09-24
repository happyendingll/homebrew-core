class Nef < Formula
  desc "Steroids for Xcode Playgrounds"
  homepage "https://nef.bow-swift.io"
  url "https://github.com/bow-swift/nef/archive/refs/tags/0.7.1.tar.gz"
  sha256 "147b8723d65ababedd04abf2ea4445c2b16dd7c18814a92182ae61978eb1152e"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "c7520bd05790edf56d1f058a33e26ddb44fb39ea0464a1a14e86ef44be9eb1bb"
  end

  depends_on :macos
  depends_on xcode: "13.1"

  def install
    # Work around Homebrew's sandbox causing build to lock up
    inreplace "Makefile", /^\t\$\(MAKE\) (bash|zsh)$/, ""

    system "make", "install", "prefix=#{prefix}", "version=#{version}"
  end

  test do
    # Nothing works in Homebrew's sandbox
    assert_path_exists bin/"nef"
  end
end
