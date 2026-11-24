class AiCli < Formula
  desc "Generate images, video, audio, and text from the terminal"
  homepage "https://ai-cli.dev"
  url "https://registry.npmjs.org/ai-cli/-/ai-cli-0.9.2.tgz"
  sha256 "1c4977b48315b0e58a17364ff5ce4b14661f66b534b4adca94213958c325f07a"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "2ced25a6753f8ca7b16faf22066005c14764dc28d2dea9eedd05b158d96e66fb"
  end

  depends_on "node"

  allow_network_access! :build

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    output = shell_output("#{bin}/ai text --image #{testpath}/missing.png describe 2>&1", 1)
    assert_match "could not read reference image", output
  end
end
