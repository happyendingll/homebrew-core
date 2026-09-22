class CloudflareWrangler < Formula
  desc "CLI tool for Cloudflare Workers"
  homepage "https://developers.cloudflare.com/workers/"
  url "https://registry.npmjs.org/wrangler/-/wrangler-4.136.0.tgz"
  sha256 "330f6e66b53bd501d145fa306373c4efe5917b9b0be478b9c252a963bcb9eef0"
  license any_of: ["Apache-2.0", "MIT"]

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "77f8ffd37aa0846aeb1de492bb1aace79a53cc83d14b12c353100950b82a7abc"
    sha256 cellar: :any, arm64_tahoe:       "77f8ffd37aa0846aeb1de492bb1aace79a53cc83d14b12c353100950b82a7abc"
    sha256 cellar: :any, arm64_sequoia:     "77f8ffd37aa0846aeb1de492bb1aace79a53cc83d14b12c353100950b82a7abc"
    sha256 cellar: :any, arm64_linux:       "54f6197e6d39d048630094b5362935810e2e46dba21eae054106ccd37cf9ee71"
    sha256 cellar: :any, x86_64_linux:      "97108ed8a5b81aba332bafacdb410b2923e601964d1d446431b0d756dfde80aa"
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
