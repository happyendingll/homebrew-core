class GitFlowNext < Formula
  desc "Modern implementation of the Git-flow branching model"
  homepage "https://git-flow.sh/"
  url "https://github.com/gittower/git-flow-next/archive/refs/tags/v2.1.0.tar.gz"
  sha256 "a122ddd1e772fb57271b760400e334f5820d7dcbf9f3f6e080e976e4b978cbeb"
  license "BSD-2-Clause"
  head "https://github.com/gittower/git-flow-next.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "b17a60577479cfd0d57c5e0bb66f2093b7b7f2bdaa9e98b44954686f14ee8395"
  end

  depends_on "go" => :build

  conflicts_with "git-flow", because: "both install the same binaries"

  def install
    commit = build.head? ? Utils.git_short_head : tap.user
    ldflags = %W[
      -X github.com/gittower/git-flow-next/version.BuildTime=#{time.iso8601}
      -X github.com/gittower/git-flow-next/version.GitCommit=#{commit}
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"git-flow")
  end

  test do
    system "git", "init"
    system "git", "config", "user.name", "BrewTestBot"
    system "git", "config", "user.email", "BrewTestBot@test.com"
    system "git", "flow", "init", "--defaults"
    system "git", "flow", "config"
    assert_equal "develop", shell_output("git symbolic-ref --short HEAD").chomp
    assert_match version.to_s, shell_output("#{bin}/git-flow version")
  end
end
