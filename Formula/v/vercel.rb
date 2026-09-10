class Vercel < Formula
  desc "Command-line interface for Vercel"
  homepage "https://vercel.com/home"
  url "https://registry.npmjs.org/vercel/-/vercel-59.13.1.tgz"
  sha256 "5f369083e5f038208951f5fe0b2a28aa88fd83090619bc1a8cb7a1013b14fa3f"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "1ac822e7e2a2c87da776a537d05d9f159c9b571d89447d4fb81708c1adb88174"
    sha256 cellar: :any,                 arm64_sequoia: "1ac822e7e2a2c87da776a537d05d9f159c9b571d89447d4fb81708c1adb88174"
    sha256 cellar: :any,                 arm64_sonoma:  "1ac822e7e2a2c87da776a537d05d9f159c9b571d89447d4fb81708c1adb88174"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "8254d98146162def04ad31b591deeb50a00c390be9a2ccf2e4486af32699e106"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d8745c8e858e58475e1e9b4ff75713168b3816458b49d5f4f8d5d4a6c9dce6c6"
  end

  depends_on "node"

  def install
    inreplace "dist/index.js", "await getUpdateCommand()",
                               '"brew upgrade vercel"'

    system "npm", "install", *std_npm_args
    node_modules = libexec/"lib/node_modules/vercel/node_modules"

    deuniversalize_machos node_modules/"fsevents/fsevents.node" if OS.mac?

    proxy_arch = Hardware::CPU.intel? ? "amd64" : "arm64"
    ["@vercel/go", "@vercel/rust"].each do |package|
      (node_modules/package/"bin").glob("**/proxy-*").each do |f|
        next if OS.linux? && f.basename.to_s == "proxy-linux-#{proxy_arch}"

        rm f
      end
    end

    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    system bin/"vercel", "init", "jekyll"
    assert_path_exists testpath/"jekyll/_config.yml", "_config.yml must exist"
    assert_path_exists testpath/"jekyll/README.md", "README.md must exist"
  end
end
