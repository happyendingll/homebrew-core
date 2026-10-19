class FernApi < Formula
  desc "Stripe-level SDKs and Docs for your API"
  homepage "https://buildwithfern.com/"
  url "https://registry.npmjs.org/fern-api/-/fern-api-5.164.0.tgz"
  sha256 "8919b92ccaf038721fc1a67ccec21a077d64f018201ae6ebe2dda16e7466f4cc"
  license "Apache-2.0"

  livecheck do
    throttle 5
  end

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "ccdba06f68dfae26357f0f5231891cba1f2d641b08163eb10300d2c763f67ea1"
    sha256 cellar: :any,                 arm64_tahoe:       "ccdba06f68dfae26357f0f5231891cba1f2d641b08163eb10300d2c763f67ea1"
    sha256 cellar: :any,                 arm64_sequoia:     "ccdba06f68dfae26357f0f5231891cba1f2d641b08163eb10300d2c763f67ea1"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "0aeaea01870c27cc93edb4b28903edbc5d8f21f346a4ec2cafeddfc90489b05f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "2ecac0c70a1e8b13e4ed4a5461fa39c8bac1e11d8ba5f5c131a71d8e5eeacc39"
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
