class Deepline < Formula
  desc "CLI for Deepline data enrichment and durable plays"
  homepage "https://code.deepline.com"
  url "https://registry.npmjs.org/deepline/-/deepline-0.3.535.tgz"
  sha256 "4322952a70f7adf1255076f25c8ede6ea6fad4dcc07f8f30f5b4b697f15fc1b2"
  license "MIT"

  livecheck do
    throttle days: 1
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "f1819841fd5f233f2773761937599ae328d65e46bb4f0e536dc9fc7339bab56e"
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
