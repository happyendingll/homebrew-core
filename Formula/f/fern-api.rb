class FernApi < Formula
  desc "Stripe-level SDKs and Docs for your API"
  homepage "https://buildwithfern.com/"
  url "https://registry.npmjs.org/fern-api/-/fern-api-5.138.0.tgz"
  sha256 "6218e0960c929d196d8fc608a2e5db316bdefea1b9e1a3151c69285bae7d768c"
  license "Apache-2.0"

  livecheck do
    throttle 5
  end

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "d1b0338d3438de188b252c8c763c9e049b3f35cbc29a7ef3074dbbd76a5db19f"
    sha256 cellar: :any,                 arm64_tahoe:       "d1b0338d3438de188b252c8c763c9e049b3f35cbc29a7ef3074dbbd76a5db19f"
    sha256 cellar: :any,                 arm64_sequoia:     "d1b0338d3438de188b252c8c763c9e049b3f35cbc29a7ef3074dbbd76a5db19f"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "bdfe218d0fba5537d52f6b29a87d32b244ffb0c4653eb9c7c42cc1ca3502396f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "8ae312d21d680acd022407510d61735ea5c1aa3cf86760876e7103852ad11b57"
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
