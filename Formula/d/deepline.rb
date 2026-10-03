class Deepline < Formula
  desc "CLI for Deepline data enrichment and durable plays"
  homepage "https://code.deepline.com"
  url "https://registry.npmjs.org/deepline/-/deepline-0.3.240.tgz"
  sha256 "d0b9dd2382ebf05839ed0e360dc00263b91b64c3413bfa52ae638933bb0ce7cf"
  license "MIT"

  livecheck do
    throttle 20
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "a5c3500e4728ad34f76211e7b0ef690b21ba237135cd158df1e096c7bc5d3189"
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
