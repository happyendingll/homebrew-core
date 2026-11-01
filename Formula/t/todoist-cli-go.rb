class TodoistCliGo < Formula
  desc "CLI for Todoist"
  homepage "https://github.com/sachaos/todoist"
  url "https://github.com/sachaos/todoist/archive/refs/tags/v0.25.0.tar.gz"
  sha256 "4ff262c32714901a7f978f7d775f43874de5784bc8d28ca3eb163bddf83a815e"
  license "MIT"
  head "https://github.com/sachaos/todoist.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "3a50dbcbdb64253661b37278d84fde82f62a32357b0433ad1bbbe257d572e6d7"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X main.version=#{version}"
    system "go", "build", *std_go_args(output: bin/"todoist", ldflags:)
  end

  def caveats
    <<~EOS
      This formula was renamed from "todoist-cli" to "todoist-cli-go" to
      free up the "todoist-cli" name for the official Doist CLI
      (https://github.com/Doist/todoist-cli).
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/todoist --version")

    test_config = testpath/".config/todoist/config.json"
    test_config.write <<~JSON
      {
        "token": "test_token"
      }
    JSON
    chmod 0600, test_config

    output = shell_output("#{bin}/todoist list 2>&1")
    assert_match "There is no task.", output
  end
end
