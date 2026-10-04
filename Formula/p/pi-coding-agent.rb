class PiCodingAgent < Formula
  desc "AI agent toolkit"
  homepage "https://pi.dev/"
  url "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-1.0.1.tgz"
  sha256 "99c2e1958ac6d4c6a36e7f1c3690ae38778bb397c63e9d611d2c09521be735c5"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c4933f5db47a21e7987c7edd09771f01196aeebd57ac4752659dcdef08f52c70"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c4933f5db47a21e7987c7edd09771f01196aeebd57ac4752659dcdef08f52c70"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c4933f5db47a21e7987c7edd09771f01196aeebd57ac4752659dcdef08f52c70"
    sha256 cellar: :any,                 arm64_linux:       "5b5241fce1a78fdb75e4985abc3bf6b220019d4be8c46c988980bb7da4ecc67c"
    sha256 cellar: :any,                 x86_64_linux:      "e3abbb4153e899716c764ce036d53c4d444db2d7d95b8b12cbc61f45dd4cdf7c"
  end

  depends_on "node"

  on_linux do
    depends_on "libxcb"
  end

  def install
    system "npm", "install", *std_npm_args
    (bin/"pi").write_env_script libexec/"bin/pi", PI_SKIP_VERSION_CHECK: "1"

    node_modules = libexec/"lib/node_modules/@earendil-works/pi-coding-agent/node_modules/"
    arch = Hardware::CPU.arm? ? "arm64" : "x64"
    os = OS.linux? ? "linux" : "darwin"
    node_modules.glob("@earendil-works/pi-tui/native/**/prebuilds/*").each do |dir|
      basename = dir.basename.to_s
      rm_r(dir) if basename != "#{os}-#{arch}"
    end

    # Rebuild the X11 clipboard helper against our `libxcb`
    system "bash", node_modules/"@earendil-works/pi-tui/native/linux/build.sh" if OS.linux?
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pi --version 2>&1")

    ENV["GEMINI_API_KEY"] = "invalid_key"
    output = shell_output("#{bin}/pi -p 'foobar' 2>&1", 1)
    assert_match "API key not valid", output
  end
end
