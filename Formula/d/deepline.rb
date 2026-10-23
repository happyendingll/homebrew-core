class Deepline < Formula
  desc "CLI for Deepline data enrichment and durable plays"
  homepage "https://code.deepline.com"
  url "https://registry.npmjs.org/deepline/-/deepline-0.3.400.tgz"
  sha256 "e9abcf7c73b56922a8d64dee59d1c4a4b2d4cee84fe398e83e7cf20dd32330f4"
  license "MIT"

  livecheck do
    throttle 20
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "1eb1eb6b1398176ca27723b6f7df0d43053898d7ac726b5b67464b322b40eafa"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    assert_match '"status": "not connected"',
      shell_output("#{bin}/deepline auth status --auth-scope folder --json")
  end
end
