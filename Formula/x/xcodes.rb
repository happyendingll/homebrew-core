class Xcodes < Formula
  desc "Command-line tool to install and switch between multiple versions of Xcode"
  homepage "https://github.com/XcodesOrg/xcodes"
  url "https://github.com/XcodesOrg/xcodes/archive/refs/tags/2.2.1.tar.gz"
  sha256 "b498c1fc59e649a771a48631d45a978e6d8feadebc6de13b99cc737343e181a6"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "5e0eb6e71fd5df5882c7b32094fcdfa54234e671a2dc13064ac024386309ca9c"
  end

  depends_on macos: :sequoia # older SDK fail to build on non-'Sendable' type 'Logger'

  uses_from_macos "swift"

  # `test do` block fetches the list of available Xcode versions
  allow_network_access! :test

  def fetch
    # SwiftPM tries to apply its own sandbox, which cannot nest inside the
    # build sandbox; Homebrew's sandbox still confines the whole process.
    system "swift", "package", "resolve", "--disable-sandbox"
  end

  def install
    system "swift", "build", *std_swift_args
    bin.install ".build/release/xcodes"
    generate_completions_from_executable(bin/"xcodes", "--generate-completion-script")
  end

  test do
    assert_match "1.0", shell_output("#{bin}/xcodes list")
  end
end
