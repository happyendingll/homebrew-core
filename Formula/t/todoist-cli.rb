class TodoistCli < Formula
  desc "Official command-line interface for Todoist"
  homepage "https://github.com/Doist/todoist-cli"
  url "https://registry.npmjs.org/@doist/todoist-cli/-/todoist-cli-5.3.8.tgz"
  sha256 "bd75c5357eb21055ad8797c195f2156afe246a6465d8ac1da4fe7ce4db80e68f"
  license "MIT"

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "a5d5dee0227c50118d761057cf225c341120e31de02da86c2b09c6dba449f8c2"
    sha256 cellar: :any,                 arm64_tahoe:       "bd3c79fb7b6686e8315785fd67eb97658535ff9ce7fb27010dd9aa8965e356dd"
    sha256 cellar: :any,                 arm64_sequoia:     "b453572317155ca671f1f21418702de22414d3687b7d5932e9be76970b904436"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "05e759a47b723a68ed30cc75a7618e67c6695042553e4e7d880991d8866d18d3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "4b852d76dc0581b7faac534bf1c540a6275be16da92e649b28c40648b4e68546"
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
