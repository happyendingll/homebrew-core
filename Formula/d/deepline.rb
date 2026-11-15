class Deepline < Formula
  desc "CLI for Deepline data enrichment and durable plays"
  homepage "https://code.deepline.com"
  url "https://registry.npmjs.org/deepline/-/deepline-0.3.505.tgz"
  sha256 "414d624dd8571af9349ce2f7c53b0e3fac7c27866e8043a2066ff5059065430c"
  license "MIT"

  livecheck do
    throttle days: 1
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "262a41b8685e5c8a9804914c652e51f2e92977e185b6d5519f1d99f4714d842d"
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
