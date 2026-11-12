class EntireCli < Formula
  desc "Capture AI agent sessions in your Git workflow"
  homepage "https://entire.com"
  url "https://github.com/entireio/cli/archive/refs/tags/v0.13.2.tar.gz"
  sha256 "15ccd6b51fd0e64d1d72bda561b9a0028e496a1a642b1e1585e5b99871a9af9f"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "3a12960451c87163e0c011e74161d198f30ea2a772eb28aec86ae97abf00b78c"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -s -w
      -X github.com/entireio/cli/cmd/entire/cli/versioninfo.Version=#{version}
      -X github.com/entireio/cli/cmd/entire/cli/versioninfo.Commit=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"entire"), "./cmd/entire"
    system "go", "build", *std_go_args(ldflags:, output: bin/"git-remote-entire"), "./cmd/git-remote-entire"

    generate_completions_from_executable(bin/"entire", "completion")
  end

  test do
    ENV["ENTIRE_TELEMETRY_OPTOUT"] = "1"

    assert_match version.to_s, shell_output("#{bin}/entire version")

    system "git", "init"
    system "git", "config", "user.name", "BrewTestBot"
    system "git", "config", "user.email", "BrewTestBot@test.com"
    system bin/"entire", "enable", "--agent", "claude-code", "--telemetry=false"

    assert_match "Entire CLI hooks", (testpath/".git/hooks/post-commit").read
    assert_path_exists testpath/".claude/settings.json"
    assert JSON.parse(shell_output("#{bin}/entire status --json"))["enabled"]

    assert_match "usage:", shell_output("#{bin}/git-remote-entire 2>&1", 128)
  end
end
