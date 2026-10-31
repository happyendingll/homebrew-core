class Deepline < Formula
  desc "CLI for Deepline data enrichment and durable plays"
  homepage "https://code.deepline.com"
  url "https://registry.npmjs.org/deepline/-/deepline-0.3.440.tgz"
  sha256 "169abc20faa1a73c55a779d209ac6c23c63818047523d257b412f46b92c95dfe"
  license "MIT"

  livecheck do
    throttle 20
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "64a53bb2755bb4a43dd65dfc9dbe004a6dfd108781f8cf5dbfaa061c66318dde"
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
