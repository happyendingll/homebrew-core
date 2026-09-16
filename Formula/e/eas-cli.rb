class EasCli < Formula
  desc "Command-line tool for working with Expo Application Services"
  homepage "https://docs.expo.dev/eas/"
  url "https://registry.npmjs.org/eas-cli/-/eas-cli-24.4.1.tgz"
  sha256 "18a867f47b84bb57f795af1432dda1d8bd89fc440ec32494caa26e22292eb374"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "40ad3bc7d5eea38e6a1b879ff1c3cd00c5aff52cd5e5bf78a35a94d305265665"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/eas --version")
    assert_match "Run this command inside a project directory",
                 shell_output("#{bin}/eas diagnostics 2>&1", 1)
  end
end
