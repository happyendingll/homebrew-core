class LaceworkCli < Formula
  desc "CLI for managing Lacework"
  homepage "https://github.com/lacework/go-sdk"
  url "https://github.com/lacework/go-sdk.git",
      tag:      "v2.19.0",
      revision: "431dc93d1ebaf0ab72b4f92290af031f06828bec"
  license "Apache-2.0"
  head "https://github.com/lacework/go-sdk.git", branch: "main"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "f0a500276fc7e1a9d740884c3f9f24790c2a3ac9f25bfef2cca619aea379dfcb"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f0a500276fc7e1a9d740884c3f9f24790c2a3ac9f25bfef2cca619aea379dfcb"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f0a500276fc7e1a9d740884c3f9f24790c2a3ac9f25bfef2cca619aea379dfcb"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "c3688a6eb1c7bc6bbadbb6e6074f028bbb8851b458c0aaeb931fe14296543a92"
    sha256 cellar: :any,                 x86_64_linux:      "f0e42323187c34b8983d6d6a917780b3ee9a42c38a7d9d2a534cada8c7f3da31"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -X github.com/lacework/go-sdk/v2/cli/cmd.Version=#{version}
      -X github.com/lacework/go-sdk/v2/cli/cmd.GitSHA=#{Utils.git_head}
      -X github.com/lacework/go-sdk/v2/cli/cmd.HoneyDataset=lacework-cli-prod
      -X github.com/lacework/go-sdk/v2/cli/cmd.BuildTime=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(output: bin/"lacework", ldflags:), "./cli"

    generate_completions_from_executable(bin/"lacework", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lacework version")

    output = shell_output("#{bin}/lacework configure list 2>&1", 1)
    assert_match "ERROR unable to load profiles. No configuration file found.", output
  end
end
