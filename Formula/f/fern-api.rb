class FernApi < Formula
  desc "Stripe-level SDKs and Docs for your API"
  homepage "https://buildwithfern.com/"
  url "https://registry.npmjs.org/fern-api/-/fern-api-5.176.0.tgz"
  sha256 "8b7f3fef81371d0280743acc71cd5e440a936d4f2a19cd041861a537200b2e58"
  license "Apache-2.0"

  livecheck do
    throttle 5
  end

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "58ea3d2b877a2dfb46d5b8561022a5de5632a6ae88253eb844127cb5ddc6bade"
    sha256 cellar: :any,                 arm64_tahoe:       "58ea3d2b877a2dfb46d5b8561022a5de5632a6ae88253eb844127cb5ddc6bade"
    sha256 cellar: :any,                 arm64_sequoia:     "58ea3d2b877a2dfb46d5b8561022a5de5632a6ae88253eb844127cb5ddc6bade"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "f25bb20e495116941a6854d5c0e6375b120eaa917e83ae59c325d80c4cfb33b4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "47d0207e22649dfd0e000ae4248b12da8588bf87e2509dd9c33923c29e913e1c"
  end

  depends_on "node"

  def install
    # Supress self update notifications
    inreplace "cli.cjs", "await this.nudgeUpgradeIfAvailable()", "await 0"
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    system bin/"fern", "init", "--docs", "--org", "brewtest"
    assert_path_exists testpath/"fern/docs.yml"
    assert_match '"organization": "brewtest"', (testpath/"fern/fern.config.json").read

    system bin/"fern", "--version"
  end
end
