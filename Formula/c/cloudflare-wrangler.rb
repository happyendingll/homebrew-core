class CloudflareWrangler < Formula
  desc "CLI tool for Cloudflare Workers"
  homepage "https://developers.cloudflare.com/workers/"
  url "https://registry.npmjs.org/wrangler/-/wrangler-4.140.0.tgz"
  sha256 "4eede4ac0f8863c714a45476cae57bb7741cf54ec61d731548ddcbdce15e2825"
  license any_of: ["Apache-2.0", "MIT"]

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "3ea631d592463b076c0ad649427d6a42f90762ac4b9bbc5e92a5b175deb3aeb7"
    sha256 cellar: :any, arm64_tahoe:       "3ea631d592463b076c0ad649427d6a42f90762ac4b9bbc5e92a5b175deb3aeb7"
    sha256 cellar: :any, arm64_sequoia:     "3ea631d592463b076c0ad649427d6a42f90762ac4b9bbc5e92a5b175deb3aeb7"
    sha256 cellar: :any, arm64_linux:       "35391aba81ff9f18cbcab1745899a55dafd57bc062adcc63738d700cc889e607"
    sha256 cellar: :any, x86_64_linux:      "97a5d86af87cf093e1c43e762353de384e1cbf632c6e4713926c257c2ee54f82"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/wrangler*"]

    node_modules = libexec/"lib/node_modules/wrangler/node_modules"
    deuniversalize_machos node_modules/"fsevents/fsevents.node" if OS.mac?

    generate_completions_from_executable(bin/"wrangler", "complete", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/wrangler -v")
    assert_match "Required Worker name missing", shell_output("#{bin}/wrangler secret list 2>&1", 1)
  end
end
