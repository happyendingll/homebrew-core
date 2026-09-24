class FernApi < Formula
  desc "Stripe-level SDKs and Docs for your API"
  homepage "https://buildwithfern.com/"
  url "https://registry.npmjs.org/fern-api/-/fern-api-5.133.0.tgz"
  sha256 "8284a18d071a4defc571cb1fac7c78bcad6713efaa0a61b73ab51914f5a8cd00"
  license "Apache-2.0"

  livecheck do
    throttle 5
  end

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "e6686a81ff9184c70a9e6ca1907f31c46e60570b8637bd3efd8c577f91a57555"
    sha256 cellar: :any,                 arm64_tahoe:       "e6686a81ff9184c70a9e6ca1907f31c46e60570b8637bd3efd8c577f91a57555"
    sha256 cellar: :any,                 arm64_sequoia:     "e6686a81ff9184c70a9e6ca1907f31c46e60570b8637bd3efd8c577f91a57555"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "38428d594b9c6a4bfd5ff0674b1d369904fb02dd7dea6a4aa4fd50b33e10b5bf"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "7b8ca76f4fcb72145407c00dd55c95d3d698f67cf8ea81d519b3bd028a4e012c"
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
