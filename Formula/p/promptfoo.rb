class Promptfoo < Formula
  desc "Test your LLM app locally"
  homepage "https://promptfoo.dev/"
  url "https://registry.npmjs.org/promptfoo/-/promptfoo-0.125.0.tgz"
  sha256 "0a77f65bb179f2ccc22a61016b29036238f74e60db67ee43b1a5e6b9aa31b709"
  license "MIT"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "eafe9a52bb615ba9d6379053f208a961b3d83694949316bbc8547d0dfff92ba7"
    sha256 cellar: :any, arm64_tahoe:       "c85d7dbcce62279f3d72d68c8440fc5264dbb43c36f4e321682aadd262bdb413"
    sha256 cellar: :any, arm64_sequoia:     "876896b28a86be2feef7fdce4bce136529e71d836dc0e4befb86f39686666ecc"
    sha256 cellar: :any, arm64_linux:       "35b3af2427f395ac5eecc14487b4a111a8362511019a13832b98823e4b203b4b"
    sha256 cellar: :any, x86_64_linux:      "d0443a890947b62c1ffc6dccd7384cc61e6ce9c79e0d4cdabff0c33fd54dc800"
  end

  depends_on "cmake" => :build # for `libsql-js` > `libsql-ffi`
  depends_on "rust" => :build # for `libsql-js`
  depends_on "node"

  resource "libsql-js" do
    url "https://github.com/tursodatabase/libsql-js/archive/refs/tags/v0.5.29.tar.gz"
    sha256 "e7ccf7f0ade06158bac3f5fffe69d9707741940678aadec75319713e21b57c21"

    livecheck do
      url :url
      regex(/^v?(\d+(:?\.\d+)+)$/i)
    end
  end

  def install
    # NOTE: We need to disable optional dependencies to avoid proprietary @anthropic-ai/claude-agent-sdk;
    # however, npm global install seems to ignore `--omit` flags. To work around this, we perform a local
    # install and then symlink it using `brew link`.
    (libexec/"promptfoo").install buildpath.children
    cd libexec/"promptfoo" do
      # openai 7.41+ declares a `google-auth-library <11` peer that conflicts with promptfoo's `^11`
      inreplace "package.json", '"openai": "^7.20.0"', '"openai": "7.40.0"'
      system "npm", "install", "--omit=dev", "--omit=optional", *std_npm_args(prefix: false)

      resource("libsql-js").stage do
        ENV.append_to_rustflags "--cfg tokio_unstable"
        system "cargo", "build", "--lib", "--release"

        arch = Hardware::CPU.arm? ? "arm64" : "x64"
        libsql_target = OS.mac? ? "darwin-#{arch}" : "linux-#{arch}-gnu"
        binding_dir = libexec/"promptfoo/node_modules/@libsql/#{libsql_target}"

        binding_dir.install "target/release/#{shared_library("liblibsql_js")}" => "index.node"
      end

      with_env(npm_config_prefix: libexec) do
        system "npm", "link"
      end
    end

    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    ENV["PROMPTFOO_DISABLE_TELEMETRY"] = "1"

    system bin/"promptfoo", "init", "--no-interactive"
    assert_path_exists testpath/"promptfooconfig.yaml"
    assert_match 'description: "My eval"', (testpath/"promptfooconfig.yaml").read

    assert_match version.to_s, shell_output("#{bin}/promptfoo --version")
  end
end
