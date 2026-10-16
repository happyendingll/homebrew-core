class EasCli < Formula
  desc "Command-line tool for working with Expo Application Services"
  homepage "https://docs.expo.dev/eas/"
  url "https://registry.npmjs.org/eas-cli/-/eas-cli-24.14.0.tgz"
  sha256 "68d619cf58989b51ed9a72df8db690ff6ec232e829531dd719cb580c98a9a517"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "d6c26dd783612367667c1a68c5d78be8744b1cf44aebf640527b63ba49a319f5"
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
