class Ipsw < Formula
  desc "Research tool for iOS & macOS devices"
  homepage "https://blacktop.github.io/ipsw"
  url "https://github.com/blacktop/ipsw/archive/refs/tags/v3.1.719.tar.gz"
  sha256 "b28560b7d9f20ffe07f0c0c958bab03b86b3b29f040c0a1efa33ac9c314e52a4"
  license "MIT"
  head "https://github.com/blacktop/ipsw.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "b6143101f69b04338ada1c1beed9b2ac88cd71bbc2106b3bbbdcc6c40b4a076f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4e8fe4c02e24483b193723737d67366e7fbbd092f79c680aea78ebf55c092fb3"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f2a7101785a91ffed0d821f1397c14c9b35341c06249b3a5e697d3008c66ac9f"
    sha256 cellar: :any,                 arm64_linux:       "34ad9b6d563131ce9ee096cb5f07b862a1db35ef7c7f9eba5712a221687061e8"
    sha256 cellar: :any,                 x86_64_linux:      "d026068d97c4087e3c7c49e1671b7995d56266e98dc1e843d224d294c085dbc8"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

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
