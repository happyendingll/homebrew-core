class EntireCli < Formula
  desc "Capture AI agent sessions in your Git workflow"
  homepage "https://entire.io"
  url "https://github.com/entireio/cli/archive/refs/tags/v0.12.2.tar.gz"
  sha256 "45beafa8e260c4fb3e74368b8e27ab7d77c407db5e4fa3e77ff38e67ff592e26"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "ef7686c9fbee6c3c6813ef13161b1d69ada5bce6b1625467ceb234ea046597ee"
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
