class ContentfulCli < Formula
  desc "Contentful command-line tools"
  homepage "https://github.com/contentful/contentful-cli"
  url "https://registry.npmjs.org/contentful-cli/-/contentful-cli-4.0.14.tgz"
  sha256 "6e3e5576ffc6e8c782778d1f79e6d27a08386213f631d295b51491f93cdc7a5b"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "af99905e07bb7805350b1ea2c6d8d5a333a74c49fe25ca624362a121a9497729"
  end

  depends_on "node"

  def install
    # The npm release is already transpiled; do not install its native build-only compiler.
    package_json = JSON.parse((buildpath/"package.json").read)
    package_json.fetch("dependencies").delete("typescript")
    (buildpath/"package.json").atomic_write(JSON.generate(package_json))

    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    output = shell_output("#{bin}/contentful space list 2>&1", 1)
    assert_match "🚨  Error: You have to be logged in to do this.", output
    assert_match "You can log in via contentful login", output
    assert_match "Or provide a management token via --management-token argument", output
  end
end
