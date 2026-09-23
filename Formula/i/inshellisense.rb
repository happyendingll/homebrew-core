class Inshellisense < Formula
  desc "IDE style command-line auto complete"
  homepage "https://github.com/microsoft/inshellisense"
  url "https://registry.npmjs.org/@microsoft/inshellisense/-/inshellisense-0.0.4.tgz"
  sha256 "413c9a1657bb5b31353dbb372e25934a712c57857bd09199889f6cb64c441fb7"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "e7715518e62e48e1f1096381e91995ea920ddda0007c93a804441a9d920bc721"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    assert_match "inshellisense session", shell_output("#{bin}/is --check")
  end
end
