class Nub < Formula
  desc "Fast TypeScript runtime and package manager that augments Node"
  homepage "https://nubjs.com"
  url "https://github.com/nubjs/nub/archive/refs/tags/v0.9.3.tar.gz"
  sha256 "a59fa2e65d500eace079aa5ee0168af57fac71e2a2dd168dbb6ff11a8d163ffb"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "3b227103583f271825c4557d0ab5130bdeed147c7c29b97f0c0f5d49e2c4cf31"
  end

  depends_on "cmake" => :build
  depends_on "node" => [:build, :test]
  depends_on "rust" => :build

  def install
    # `runtime` has no package.json, so npm resolves up to the repository root
    # either way. Install there, where package-lock.json pins the versions.
    system "npm", "install", *std_npm_args(prefix: false)

    # The `embed-runtime` feature tars `runtime` into the binary, and the tree that
    # binary extracts at runtime has no parent node_modules to resolve through. Copy
    # in the packages that tree loads: the transpile helpers and the web API
    # polyfills. Without them the build still succeeds, but the binary fails to run
    # any file that needs a helper and silently drops Temporal, URLPattern and
    # Float16Array on Node versions that lack them natively.
    %w[
      @js-temporal/polyfill
      @oxc-project/runtime
      @petamoriken/float16
      jsbi
      urlpattern-polyfill
    ].each do |dep|
      (buildpath/"runtime/node_modules"/dep).dirname.mkpath
      cp_r buildpath/"node_modules"/dep, buildpath/"runtime/node_modules"/dep
    end

    cd "crates/nub-native" do
      system "cargo", "build", "--release", "--lib"
    end
    mkdir_p "runtime/addons"
    cp shared_library("target/release/libnub_native"), "runtime/addons/nub-native.node"

    system "cargo", "install", *std_cargo_args(path: "crates/nub-cli", features: ["embed-runtime"])
    bin.install_symlink bin/"nub" => "nubx"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nub --version")
    assert_match "Usage: nub nubx", shell_output("#{bin}/nubx --help")

    (testpath/"package.json").write <<~JSON
      {
        "name": "test-app",
        "version": "1.0.0"
      }
    JSON

    # Transpile a file that pulls a helper out of the vendored runtime node_modules.
    # Legacy decorators are down-levelled on every Node version, so this covers the
    # embedded runtime whichever Node is on PATH.
    (testpath/"tsconfig.json").write <<~JSON
      {"compilerOptions": {"experimentalDecorators": true, "emitDecoratorMetadata": true}}
    JSON
    (testpath/"decorated.ts").write <<~TYPESCRIPT
      function log(target: any, key: string, descriptor: PropertyDescriptor) { return descriptor; }
      class Greeter { @log greet(): string { return "hello nub"; } }
      console.log(new Greeter().greet());
    TYPESCRIPT
    assert_equal "hello nub", shell_output("#{bin}/nub decorated.ts").strip

    system bin/"nub", "config", "set", "registry", "https://registry.npmjs.org"
    assert_match "https://registry.npmjs.org", shell_output("#{bin}/nub config get registry")
  end
end
