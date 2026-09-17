class Vercel < Formula
  desc "Command-line interface for Vercel"
  homepage "https://vercel.com/home"
  url "https://registry.npmjs.org/vercel/-/vercel-59.19.0.tgz"
  sha256 "17f9425a953a68614617574e2127e57c0b5239bbedd3421e85ebf5edf55bf031"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "e0c3d57abd592e7bd98712001cf314fbcfd521158edf2616811a58c9eee4e6f1"
    sha256 cellar: :any,                 arm64_tahoe:       "e0c3d57abd592e7bd98712001cf314fbcfd521158edf2616811a58c9eee4e6f1"
    sha256 cellar: :any,                 arm64_sequoia:     "e0c3d57abd592e7bd98712001cf314fbcfd521158edf2616811a58c9eee4e6f1"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "2c08c63da36496b54316fe55eab2d7f3751beb07a2272c7bf27f2e287094c945"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "4a40efe0b201683f58d7412db05a7ba72448bbf28ed53c4d9b73819be3705fd9"
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
