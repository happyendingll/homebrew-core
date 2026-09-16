class EasCli < Formula
  desc "Command-line tool for working with Expo Application Services"
  homepage "https://docs.expo.dev/eas/"
  url "https://registry.npmjs.org/eas-cli/-/eas-cli-24.4.2.tgz"
  sha256 "1d5a5755b47a28db4743d8a18b6dc9c148fe0a0caa914998d8653f85dba5dcd0"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "d134027da50497ed575d7311a6b327fd5417d35feb668fda582e559bf004c063"
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
