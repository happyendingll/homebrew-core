class Vercel < Formula
  desc "Command-line interface for Vercel"
  homepage "https://vercel.com/home"
  url "https://registry.npmjs.org/vercel/-/vercel-60.0.1.tgz"
  sha256 "419e5f7889bf225bd6f212758a8323ccc22dab2df7d3bc6baeb50ea8cbcd796b"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "034f7abc0f40d408626f3aa115256d0d6d8ac4b0f62675d2b3657c5d0fb54336"
    sha256 cellar: :any,                 arm64_tahoe:       "034f7abc0f40d408626f3aa115256d0d6d8ac4b0f62675d2b3657c5d0fb54336"
    sha256 cellar: :any,                 arm64_sequoia:     "034f7abc0f40d408626f3aa115256d0d6d8ac4b0f62675d2b3657c5d0fb54336"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "58064a1eb5be29454d6a60964431d47fb0531b7016341704ef73da2e34725b8c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "50990367229d2661f191215fa45c0c7fb3b36cee50e08a12b755258eae4f6771"
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
