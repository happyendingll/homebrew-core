class LettaCode < Formula
  desc "Memory-first coding agent"
  homepage "https://docs.letta.com/letta-code"
  url "https://registry.npmjs.org/@letta-ai/letta-code/-/letta-code-0.32.8.tgz"
  sha256 "5fdf2ffce964f0bea52a5b174ed63d34b6921414c18a5503eecad8bf0ccb91df"
  license "Apache-2.0"

  bottle do
    sha256               arm64_golden_gate: "9c6927e2f7a8a67344243669370a5d3449e66dad72bf0da761a6d654e3c15f4d"
    sha256               arm64_tahoe:       "0c05ba7e61777d310b723a6866a0830c356e754ea9c115cfe85edba9ef806a18"
    sha256               arm64_sequoia:     "86b43803bff1beb6486176dc9f77c0622c598da4ff1f9691a2cdcfa8387cf230"
    sha256 cellar: :any, arm64_linux:       "26ce2fcea6f548c39f0cde7e3ab8ade8669678037b5eca79535121d2433d46f0"
    sha256 cellar: :any, x86_64_linux:      "ed959d5201ac0c19cfc41296918ae489cb2ec573c73271354a484c7efda9bcc2"
  end

  depends_on "pkgconf" => :build
  depends_on "glib"
  depends_on "node"
  depends_on "ripgrep"
  depends_on "vips"

  on_macos do
    depends_on "gettext"
  end

  resource "node-gyp" do
    url "https://registry.npmjs.org/node-gyp/-/node-gyp-13.0.2.tgz"
    sha256 "1b1524d914331bd01312729e31a828192d53af84e113dacb6e36afabb6c21a6d"

    livecheck do
      url :url
    end
  end

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    # Remove ripgrep pre-built binaries
    node_modules = libexec/"lib/node_modules/@letta-ai/letta-code/node_modules"
    rm_r(node_modules.glob("@vscode/ripgrep-*"))
    rm_r(node_modules/"@vscode/ripgrep") # keeping separate from previous rm_r to fail if missing

    # Remove Electron-only sharp fork with x86_64-only pre-built binaries
    rm_r(node_modules/"@janhapke")

    # Replace node-pty pre-built binaries
    cd node_modules/"node-pty" do
      rm_r(["prebuilds", "third_party"])
      system "npm", "run", "install"
    end

    # Replace sharp pre-built binaries
    rm_r(node_modules.glob("@img/sharp-*"))
    resource("node-gyp").stage do
      system "npm", "install", *std_npm_args(prefix: buildpath/"node-gyp")
      ENV.append_path "NODE_PATH", buildpath/"node-gyp/lib/node_modules"
    end
    cd node_modules/"sharp" do
      ENV["SHARP_FORCE_GLOBAL_LIBVIPS"] = "1"
      system "npm", "run", "build"
      rm_r("src/build/Release/obj.target")

      # help letta.js find source-built sharp
      sharp = Pathname.pwd.glob("src/build/Release/sharp-*.node").first
      (node_modules/"@img"/sharp.basename(".node")).install_symlink sharp => "sharp.node"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/letta --version")

    output = shell_output("#{bin}/letta --info")
    assert_match "Pinned agents: (none)", output
  end
end
