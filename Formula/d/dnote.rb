class Dnote < Formula
  desc "Simple command-line notebook"
  homepage "https://www.getdnote.com"
  url "https://github.com/dnote/dnote/archive/refs/tags/cli-v0.17.0.tar.gz"
  sha256 "29a15bc4e397a1c02117adc1e5a35ff8f6bd35d50cb36f570144a3d10c2ed0bc"
  license "Apache-2.0"
  head "https://github.com/dnote/dnote.git", branch: "master"

  livecheck do
    url :stable
    regex(/^cli[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "4b42a6bd3994a025b802afec3a81f78e7990cc493cf09643454073bea23c0469"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    ldflags = "-X main.versionTag=#{version} -X main.apiEndpoint=http://localhost:3001/api"
    system "go", "build", *std_go_args(ldflags:, tags: "fts5"), "./pkg/cli"
  end

  test do
    ENV["XDG_CONFIG_HOME"] = testpath
    ENV["XDG_DATA_HOME"] = testpath
    ENV["XDG_CACHE_HOME"] = testpath

    assert_match version.to_s, shell_output("#{bin}/dnote version")

    desc = "Check disk usage with df -h"
    system bin/"dnote", "add", "linux", "-c", desc
    assert_match desc, shell_output("#{bin}/dnote view linux")
    assert_match desc, shell_output("#{bin}/dnote find 'disk usage'")
  end
end
