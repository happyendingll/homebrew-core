class BitbucketCli < Formula
  desc "CLI for Bitbucket Cloud and Data Center"
  homepage "https://github.com/avivsinai/bitbucket-cli"
  url "https://github.com/avivsinai/bitbucket-cli/archive/refs/tags/v0.35.0.tar.gz"
  sha256 "509d013e2c6a0ae68c20fb01e78096cce40647a65ac935a48b9249aebe57a504"
  license "MIT"
  head "https://github.com/avivsinai/bitbucket-cli.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "e3f07cb7be074cde26f6d925342fb8e4c637b81543e488391e411544b9429c17"
  end

  depends_on "go" => :build

  conflicts_with "bkt", because: "both install `bkt` binaries"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/avivsinai/bitbucket-cli/internal/build.versionFromLdflags=#{version}
      -X github.com/avivsinai/bitbucket-cli/internal/build.dateFromLdflags=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"bkt"), "./cmd/bkt"
    generate_completions_from_executable(bin/"bkt", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bkt --version")
    assert_match "No contexts configured", shell_output("#{bin}/bkt context list")
    assert_match "no active context", shell_output("#{bin}/bkt repo list 2>&1", 1)
  end
end
