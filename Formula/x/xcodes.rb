class Xcodes < Formula
  desc "Command-line tool to install and switch between multiple versions of Xcode"
  homepage "https://github.com/XcodesOrg/xcodes"
  url "https://github.com/XcodesOrg/xcodes/archive/refs/tags/2.1.0.tar.gz"
  sha256 "884c6d0c50528ccc660e22499edcd324f3a5e6f7e2f7006933ddb6eb278f6387"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "e1b6ebb1000d65396d472df3bb31afd96f597263317bc8d5593f31ca732a0ff1"
  end

  depends_on macos: :sequoia # older SDK fail to build on non-'Sendable' type 'Logger'

  uses_from_macos "swift"

  def install
    system "swift", "build", *std_swift_args
    bin.install ".build/release/xcodes"
    generate_completions_from_executable(bin/"xcodes", "--generate-completion-script")
  end

  test do
    assert_match "1.0", shell_output("#{bin}/xcodes list")
  end
end
