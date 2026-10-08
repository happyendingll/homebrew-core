class Deepline < Formula
  desc "CLI for Deepline data enrichment and durable plays"
  homepage "https://code.deepline.com"
  url "https://registry.npmjs.org/deepline/-/deepline-0.3.280.tgz"
  sha256 "0f60de931abda9e6a54862fc755b0cd8422cd4feb81c1c832151eeb0800b9140"
  license "MIT"

  livecheck do
    throttle 20
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "79f870dc02080bc11fb133d23471a2ea23d0fbffbf1d954cf909fd2643057d3f"
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
