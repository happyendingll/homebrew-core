class OsctrlMcp < Formula
  desc "Fast and efficient osquery management"
  homepage "https://docs.osctrl.net/components/osctrl-mcp/"
  url "https://github.com/jmpsec/osctrl/archive/refs/tags/v0.6.3.tar.gz"
  sha256 "7f6e4a260f24d37f19bc955d42bb0babfc1224af43e8db7d017f21c326404df0"
  license "MIT"
  head "https://github.com/jmpsec/osctrl.git", branch: "develop"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "b93cff87f297a75e8c2160ffd614700e3a2956a93aff675329c8259efa052792"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    commit = build.head? ? Utils.git_head : Utils::Git.get_tar_commit_id(cached_download)
    ldflags = %W[
      -X main.buildVersion=#{version}
      -X main.buildCommit=#{commit}
      -X main.buildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/mcp"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/osctrl-mcp --version")

    output = shell_output("#{bin}/osctrl-mcp --api-url aaa 2>&1", 1)
    assert_match "no API token", output
  end
end
