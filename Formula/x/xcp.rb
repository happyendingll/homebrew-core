class Xcp < Formula
  desc "Fast & lightweight command-line tool for managing Xcode projects, built in Swift"
  homepage "https://github.com/wojciech-kulik/XcodeProjectCLI"
  url "https://github.com/wojciech-kulik/XcodeProjectCLI/archive/refs/tags/v1.2.3.tar.gz"
  sha256 "47e282024767603d31eed14ccc7082585409df58b7a8eca9009be3f4fce2b814"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "c76f5dae431830c77262036ab605b63d28d4378442c9de5db39bae78c0ae59ce"
  end

  depends_on xcode: ["15.0", :build]
  depends_on :macos

  def install
    system "swift", "build", *std_swift_args
    bin.install ".build/release/xcp"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/xcp --version")
    assert_match "Error: The project doesn't contain a .pbxproj file at path: #{testpath}",
                 shell_output("#{bin}/xcp list-targets 2>&1", 1)
  end
end
