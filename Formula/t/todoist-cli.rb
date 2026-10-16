class TodoistCli < Formula
  desc "Official command-line interface for Todoist"
  homepage "https://github.com/Doist/todoist-cli"
  url "https://registry.npmjs.org/@doist/todoist-cli/-/todoist-cli-5.5.0.tgz"
  sha256 "813e1d252374345cf80a6f740c4295798826abff869b1205f46fa54cf5d30b5e"
  license "MIT"

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "06aea6f4340e1fd46ab41fcd57898e8412fe73b9fa250627ba8ce70c01f06759"
    sha256 cellar: :any,                 arm64_tahoe:       "45913584a1cac61dc37a0b2d9d2a5899cc63d22888cb1bd70e4649741147f8da"
    sha256 cellar: :any,                 arm64_sequoia:     "dcdeee071d86ecbd637bd45b5a361d59a50886a4189d07208f55b0fbc6f62a9a"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "61a9b0e36d42c07973c16b51ed4645186fbb205e681423828df618c3da4e2aad"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "07cb71fb23fd75f5e3b04df8b94fb710e12ac7779de6c066ed8e34e8af3a857c"
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
