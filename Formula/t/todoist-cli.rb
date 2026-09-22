class TodoistCli < Formula
  desc "Official command-line interface for Todoist"
  homepage "https://github.com/Doist/todoist-cli"
  url "https://registry.npmjs.org/@doist/todoist-cli/-/todoist-cli-5.3.10.tgz"
  sha256 "4bd6930b7b8d11e11ba3faaad802713e72b008567df65f5f4a161900fbf1f3e3"
  license "MIT"

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "cce5376ea3529789d47423577773d3ea02ccd7bfa9e3e38a6cbda6ca2e17955c"
    sha256 cellar: :any,                 arm64_tahoe:       "0f8955a5409851dd3a5f1d605c5a311e94bc1d8c8f69b6ac8cbecb40744456e5"
    sha256 cellar: :any,                 arm64_sequoia:     "afcdfc2ca0c11718d846ff4d5a1ba9dd147393f614f2ada6843258918395b41f"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "46fe7c9c5db76bc436b761e500546c202a779543ac4152bbc2852b027533b163"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "d205216b3e079372c9e53c325cca045243621f13f97ea1e6c74ce321f85b60d6"
  end

  depends_on "rust" => :build
  depends_on "node"

  resource "keyring" do
    url "https://github.com/Brooooooklyn/keyring-node/archive/refs/tags/v2.1.0.tar.gz"
    sha256 "dcb0381cf252c577ff5c0c3bb0d5dd0750fd04a528484e5dbfdfb3c1add12467"

    livecheck do
      url "https://raw.githubusercontent.com/Doist/todoist-cli/v#{LATEST_VERSION}/package-lock.json"
      regex(/^v?(\d+(?:\.\d+)+)$/i)
      strategy :json do |json, regex|
        json.dig("packages", "node_modules/@napi-rs/keyring", "version")&.[](regex, 1)
      end
    end
  end

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    return unless OS.mac?

    node_modules = libexec/"lib/node_modules/@doist/todoist-cli/node_modules"

    resource("keyring").stage do
      system "cargo", "build", "--lib", "--release"
      dylib = Pathname.pwd/"target/release/libnapi_keyring.dylib"
      node_modules.glob("@doist/cli-core/node_modules/@napi-rs/keyring-darwin-*/*.node").each do |prebuilt|
        cp dylib, prebuilt
      end
    end

    deuniversalize_machos node_modules/"app-path/main"
  end

  def caveats
    <<~EOS
      Looking for the third-party Go CLI previously published under this
      name (by sachaos)? It has been renamed. Install it with:
        brew install todoist-cli-go
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/td --version")
  end
end
