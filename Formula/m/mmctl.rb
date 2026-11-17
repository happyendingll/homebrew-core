class Mmctl < Formula
  desc "Remote CLI tool for Mattermost server"
  homepage "https://mattermost.com"
  url "https://github.com/mattermost/mattermost/archive/refs/tags/v12.1.0.tar.gz"
  sha256 "40f95492b8032937a473ca449a460ce76fca575bbb959229def21d8fb81d7337"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]
  head "https://github.com/mattermost/mattermost.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "e6eb62e0388f7e46cf3473f0f764ce5e486514c07018b12dfdb6b78c56c48306"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "make", "-C", "server", "setup-go-work"
    system "go", "mod", "download", "-C", "server"
  end

  def install
    # remove non open source files
    rm_r("server/enterprise")
    rm Dir["server/cmd/mmctl/commands/compliance_export*"]

    ldflags = "-X github.com/mattermost/mattermost/server/v8/cmd/mmctl/commands.buildDate=#{time.iso8601}"
    system "make", "-C", "server", "setup-go-work"
    system "go", "build", "-C", "server", *std_go_args(ldflags:), "./cmd/mmctl"

    # Install shell completions
    generate_completions_from_executable(bin/"mmctl", "completion", shells: [:bash, :zsh])
  end

  test do
    output = pipe_output("#{bin}/mmctl help 2>&1")
    refute_match(/.*No such file or directory.*/, output)
    refute_match(/.*command not found.*/, output)
    assert_match(/.*mmctl \[command\].*/, output)
  end
end
