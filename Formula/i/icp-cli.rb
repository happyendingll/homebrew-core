class IcpCli < Formula
  desc "Development tool for building and deploying canisters on ICP"
  homepage "https://dfinity.github.io/icp-cli/"
  url "https://github.com/dfinity/icp-cli/archive/refs/tags/v1.8.0.tar.gz"
  sha256 "85e37d5140f20e79a8300bea4f72ede53eb16a2de978605c511592489880ce26"
  license "Apache-2.0"
  head "https://github.com/dfinity/icp-cli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "db11914aa17e01fb99007cf5c4a034c334134f192b88be9f83bc28ce63c1674c"
  end

  depends_on "lld" => :build # for `wasm-ld`
  depends_on "rust" => :build
  depends_on "rust-wasm" => :build
  depends_on "ic-wasm"
  depends_on "openssl@4"

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "dbus"
    depends_on "zlib-ng-compat"
  end

  resource "candid_ui" do
    url "https://github.com/dfinity/candid/releases/download/2025-12-10/candid_ui.wasm"
    version "2025-12-10"
    sha256 "359e217aed87044d24155df974fb4501dec02f676b9651f040a8dfe1ac0c9ed1"

    livecheck do
      url "https://raw.githubusercontent.com/dfinity/icp-cli/refs/tags/v#{LATEST_VERSION}/crates/icp-cli/artifacts/source.json"
      regex(/(\d+(:?[._-]\d+)*)/)
      strategy :json do |json, regex|
        matches = json.dig("candid_ui", "url")&.match(regex)
        matches[1]
      end
    end
  end

  resource "proxy" do
    url "https://github.com/dfinity/proxy-canister/releases/download/v0.1.0-beta.1/proxy.wasm"
    version "0.1.0-beta.1"
    sha256 "9e5abf27930b06df7f50c4baa1ec71b7e53408cb81849054fc51a1825eb6c5a4"

    livecheck do
      url "https://raw.githubusercontent.com/dfinity/icp-cli/refs/tags/v#{LATEST_VERSION}/crates/icp-cli/artifacts/source.json"
      regex(/(\d+(:?[._-]\d+)*(:?[._-]beta[._-]\d+)?)/)
      strategy :json do |json, regex|
        matches = json.dig("proxy", "url")&.match(regex)
        matches[1]
      end
    end
  end

  deny_network_access!

  def openssl = deps.map(&:name).find { |d| d.match?(/^openssl(@\d+(\.\d+)*)?$/) }

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
    cd "crates/icp-cli/recover-cycles-canister" do
      system "cargo", "fetch", *std_cargo_fetch_args
    end
  end

  def install
    ENV["ICP_CLI_BUILD_DIST"] = "homebrew-core"
    ENV["OPENSSL_DIR"] = formula_opt_prefix(openssl)
    ENV["CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER"] = "wasm-ld"
    ENV.append_to_rustflags "--sysroot #{HOMEBREW_PREFIX}"

    # See https://github.com/dfinity/icp-cli/blob/main/crates/icp-cli/build.rs
    # and https://github.com/dfinity/icp-cli/blob/main/crates/icp-cli/artifacts/mod.rs
    artifact_dir = buildpath/"target/icp-cli-artifact-cache"
    resources.each { |r| artifact_dir.install r }
    artifact_dir.children.each { |file| mv file, file.sub_ext(".bin") }

    system "cargo", "install", *std_cargo_args(path: "crates/icp-cli")
    generate_completions_from_executable(bin/"icp", shell_parameter_format: :clap)
  end

  test do
    output = shell_output("#{bin}/icp identity new alice --storage plaintext")
    assert_match "Your seed phrase", output
  end
end
