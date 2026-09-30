class Vercel < Formula
  desc "Command-line interface for Vercel"
  homepage "https://vercel.com/home"
  url "https://registry.npmjs.org/vercel/-/vercel-61.0.0.tgz"
  sha256 "8c31b9e58f1d9baf2c99e8a8ad547fd4192afb736f4aa4923d1e91834e87385b"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "94a43dacae27effb0ac9778e752138e704e510c40a0d61a67828a56e9f3fed76"
    sha256 cellar: :any,                 arm64_tahoe:       "94a43dacae27effb0ac9778e752138e704e510c40a0d61a67828a56e9f3fed76"
    sha256 cellar: :any,                 arm64_sequoia:     "94a43dacae27effb0ac9778e752138e704e510c40a0d61a67828a56e9f3fed76"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "3e10012f5a15063367edbf5c9d372dd897721f7b0c24724e0ffa0494a7130fa0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "debd1c985139b9502de26176ac8ae1ee902d9f3d0581e82b3941c8cd6078ef59"
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
