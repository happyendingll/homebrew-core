class Vercel < Formula
  desc "Command-line interface for Vercel"
  homepage "https://vercel.com/home"
  url "https://registry.npmjs.org/vercel/-/vercel-59.25.4.tgz"
  sha256 "fd06c064296bddab1e1ee426d4c86b5365a82586531eba4c8257d19a77dd64a5"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "9f606734dca7bf731f73be6c2f9d7c1e2853527a3b42044e12eb296ecd1c35c4"
    sha256 cellar: :any,                 arm64_tahoe:       "9f606734dca7bf731f73be6c2f9d7c1e2853527a3b42044e12eb296ecd1c35c4"
    sha256 cellar: :any,                 arm64_sequoia:     "9f606734dca7bf731f73be6c2f9d7c1e2853527a3b42044e12eb296ecd1c35c4"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "aac2100c68de781bc17bd8ad0ff5964603c94f0b549c7e2b6437c3088961b611"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "c1d3b39d617506a066b30e6382f6ce2bf724ef8f793e957d08dab387674abf02"
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
