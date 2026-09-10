class Ipsw < Formula
  desc "Research tool for iOS & macOS devices"
  homepage "https://blacktop.github.io/ipsw"
  url "https://github.com/blacktop/ipsw/archive/refs/tags/v3.1.714.tar.gz"
  sha256 "bb400c9310ea7d981eb1d9f81fba672e772a5b4ca341d622dec570b1374b5507"
  license "MIT"
  head "https://github.com/blacktop/ipsw.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "50f49d964ad24b61c23efd527dd071353ae17863bf2c9a48ffb555adeabb1867"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0c936e58ad4ddf6250dfab20a8c4dc69fd19c40f042fa5cb9f4942dc3d372ddb"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "617564d0e6202629fd31412529dbe2a817ff82feb849c5ba85d55c56a25815c5"
    sha256 cellar: :any,                 arm64_linux:   "7beb84d01b248685d1e2d05f32318e09a5083c99928b0dc1298b5c96775b2cc5"
    sha256 cellar: :any,                 x86_64_linux:  "217a8d6e46fe33ec9b016952345f0c8810d4364b92d6e84dbd6ea3210dd6467d"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    ldflags = %W[
      -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppVersion=#{version}
      -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppBuildCommit=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/ipsw"
    generate_completions_from_executable(bin/"ipsw", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ipsw version")

    assert_match "iPad Pro (12.9-inch) (6th gen)", shell_output("#{bin}/ipsw device-list")
  end
end
