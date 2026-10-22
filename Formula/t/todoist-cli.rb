class TodoistCli < Formula
  desc "Official command-line interface for Todoist"
  homepage "https://github.com/Doist/todoist-cli"
  url "https://registry.npmjs.org/@doist/todoist-cli/-/todoist-cli-5.6.0.tgz"
  sha256 "13c327206440f9ab6c4bd2dbbe48df0cebe6ddd802f36446bf2401e6ed4172a5"
  license "MIT"

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "9e35ab9ed1862fd81290ded13f0266f1511d04e30a62293a3208a6b1c455d70e"
    sha256 cellar: :any,                 arm64_tahoe:       "e4a3550ef680f4de32baefd4ac542c8685e187826f60e1554769185fe8f77ff9"
    sha256 cellar: :any,                 arm64_sequoia:     "14c3326fc4d6f3b1ef827c468a608258374c0d9e9e7c88af9b191fac0e5390d9"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "4bdb002dc925b292ec1144775ca3d678a8ccc049ee683b4d17444c55c68d1970"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "28676a5e88ad535b83d423bb3307abffb05b6d9a1ee255c7301f96287392987b"
  end

  depends_on "rust" => :build
  depends_on "node"

  resource "keyring" do
    url "https://github.com/Brooooooklyn/keyring-node/archive/refs/tags/v2.1.1.tar.gz"
    sha256 "b1f4847eb61306e8c4f1a0418bf9e47231e8fdbc41a88631777d5cfa515eaaaf"

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
