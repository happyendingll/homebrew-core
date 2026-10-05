class Deepline < Formula
  desc "CLI for Deepline data enrichment and durable plays"
  homepage "https://code.deepline.com"
  url "https://registry.npmjs.org/deepline/-/deepline-0.3.260.tgz"
  sha256 "497761bea5d97c0ecca5b2362dfedbe42166ce82b9c434f88d3e9282c9a96b0c"
  license "MIT"

  livecheck do
    throttle 20
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "4cdfe00c97697626d78fececb2c3ee3b6a0bf440360d32388928757ffdb0bbc0"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    assert_match '"status": "not connected"',
      shell_output("#{bin}/deepline auth status --auth-scope folder")
  end
end
