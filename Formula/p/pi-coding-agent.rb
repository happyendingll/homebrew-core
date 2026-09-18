class PiCodingAgent < Formula
  desc "AI agent toolkit"
  homepage "https://pi.dev/"
  url "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-0.85.1.tgz"
  sha256 "1f498729649bdce647d1160993b4d92bf3c614cc819213bee2f91dd34f2a7af4"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "4355671a4243fdd4393ae4ffa98d1a6ac7967fdabe983d5995e879b84849c49e"
  end

  depends_on "node"

  on_macos do
    depends_on "rust" => :build

    resource "clipboard" do
      url "https://registry.npmjs.org/@mariozechner/clipboard/-/clipboard-0.3.9.tgz"
      sha256 "25986ebeecaffadf3d1dd5f9199869057e4b64c37d7069c7f31c231dd86b5639"
    end
  end

  def install
    system "npm", "install", *std_npm_args
    (bin/"pi").write_env_script libexec/"bin/pi", PI_SKIP_VERSION_CHECK: "1"

    node_modules = libexec/"lib/node_modules/@earendil-works/pi-coding-agent/node_modules/"
    arch = Hardware::CPU.arm? ? "arm64" : "x64"
    os = OS.linux? ? "linux" : "darwin"
    node_modules.glob("koffi/build/koffi/*").each do |dir|
      basename = dir.basename.to_s
      rm_r(dir) if basename != "#{os}_#{arch}"
    end

    node_modules.glob("@earendil-works/pi-tui/native/**/prebuilds/*").each do |dir|
      basename = dir.basename.to_s
      rm_r(dir) if basename != "#{os}-#{arch}"
    end

    return unless OS.mac?

    # Rebuild as the npm prebuilt lacks Mach-O header space to relocate install names for bottling
    resource("clipboard").stage do
      system "cargo", "build", "--lib", "--release"
      cp "target/release/libcrosscopy_clipboard.dylib",
         node_modules/"@mariozechner/clipboard-darwin-universal/clipboard.darwin-universal.node"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pi --version 2>&1")

    ENV["GEMINI_API_KEY"] = "invalid_key"
    output = shell_output("#{bin}/pi -p 'foobar' 2>&1", 1)
    assert_match "API key not valid", output
  end
end
