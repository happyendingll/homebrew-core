class TodoistCli < Formula
  desc "Official command-line interface for Todoist"
  homepage "https://github.com/Doist/todoist-cli"
  url "https://registry.npmjs.org/@doist/todoist-cli/-/todoist-cli-5.3.5.tgz"
  sha256 "afb338e98ae9b8e088b69c67ca3c26f5f95da90b84913cd3e2a800c436f13231"
  license "MIT"

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "7545362024ccc54b682b9e04541e62f2ac73d5f0fabc08114c5262cefba90a59"
    sha256 cellar: :any,                 arm64_tahoe:       "1841062383c1d70fd59ac16ede5a4d4588350a5c2af38109f2ca90f53bd138d4"
    sha256 cellar: :any,                 arm64_sequoia:     "a2447ba953d91fac436c370f3be29080961851991a7e759781c5a62c8edbc009"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "c574b34950d22d380ecaa7b479abf6c2b36ba9a42a65938fc3200b43c0bb9ea6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "de80fc024d4ac87dd6b9580deb5e3dc548d57064c3efa5aaba40c30f581b80f3"
  end

  depends_on "rust" => :build
  depends_on "node"

  resource "keyring" do
    url "https://github.com/Brooooooklyn/keyring-node/archive/refs/tags/v2.0.0.tar.gz"
    sha256 "0a3eb14fe07b733e945d25d1a5425021c728ed19886f426d22afa84fc97c7754"

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
