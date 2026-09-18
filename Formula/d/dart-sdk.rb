class DartSdk < Formula
  desc "Dart Language SDK, including the VM, dart2js, core libraries, and more"
  homepage "https://dart.dev"
  url "https://github.com/dart-lang/sdk/archive/refs/tags/3.13.4.tar.gz"
  sha256 "8a6040a7998e157e4ff6ec29141a78478aac000b372a2b065a9c53ba40cf8fa9"
  license "BSD-3-Clause"
  compatibility_version 3

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "9f2a971459eb4b036f3deaba7fb0f2e7d9982e7db43984bebd262f78b797660f"
  end

  depends_on "ninja" => :build
  depends_on "rust" => :build

  uses_from_macos "curl" => :build
  uses_from_macos "python" => :build
  uses_from_macos "xz" => :build

  # always pull the latest commit from https://chromium.googlesource.com/chromium/tools/depot_tools.git/+/refs/heads/main
  resource "depot-tools" do
    url "https://chromium.googlesource.com/chromium/tools/depot_tools.git",
        revision: "46afe8bfbb57583700c01d1584e7a49638d586ed"
    version "46afe8bfbb57583700c01d1584e7a49638d586ed"

    livecheck do
      url "https://chromium.googlesource.com/chromium/tools/depot_tools.git/+/refs/heads/main?format=JSON"
      regex(/"commit":\s*"(\h+)"/i)
    end
  end

  def install
    resource("depot-tools").stage(buildpath/"depot-tools")

    ENV["DEPOT_TOOLS_UPDATE"] = "0"
    ENV.append_path "PATH", "#{buildpath}/depot-tools"

    # Roll clang to include lld support for arm64e.x1 targets in the macOS 27 SDK (llvm/llvm-project#222721)
    # TODO: Remove when upstream rolls clang past that commit, see https://github.com/dart-lang/sdk/issues/64264
    system "gclient", "config", "--name", "sdk",
           "--custom-var", 'clang_version="git_revision:07d67299a15ce03b053736e2d31a668ee0576987"',
           "https://dart.googlesource.com/sdk.git@#{version}"
    system "gclient", "sync", "--no-history"

    chdir "sdk" do
      # The newer clang flags an unused variable in binaryen, which is built with -Werror
      inreplace "third_party/binaryen/BUILD.gn", '"-Wno-unused-private-field",',
                                                   "\\0\n        \"-Wno-unused-variable\","

      arch = Hardware::CPU.arm? ? "arm64" : "x64"
      system "./tools/build.py", "--mode=release", "--arch=#{arch}", "create_sdk"
      out = OS.linux? ? "out" : "xcodebuild"
      libexec.install Dir["#{out}/Release#{arch.upcase}/dart-sdk/*"]
    end
    bin.install_symlink libexec/"bin/dart"
  end

  test do
    system bin/"dart", "create", "dart-test"
    chdir "dart-test" do
      assert_match "Hello world: 42!", shell_output("#{bin}/dart run")
    end
  end
end
