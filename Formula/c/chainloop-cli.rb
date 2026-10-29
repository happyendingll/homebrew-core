class ChainloopCli < Formula
  desc "CLI for interacting with Chainloop"
  homepage "https://docs.chainloop.dev"
  url "https://github.com/chainloop-dev/chainloop/archive/refs/tags/v1.129.0.tar.gz"
  sha256 "9054c69cafb2f279519839e31adcd20397ee1cc71321adcc1f09c79c483beebc"
  license "Apache-2.0"
  head "https://github.com/chainloop-dev/chainloop.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "25431c57a9726d9a4f5295e167d0b3fedf2bfe83ee70b7181735cb0d86a70d4a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "25431c57a9726d9a4f5295e167d0b3fedf2bfe83ee70b7181735cb0d86a70d4a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "25431c57a9726d9a4f5295e167d0b3fedf2bfe83ee70b7181735cb0d86a70d4a"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "86ed4a0b29638f5cf7de7283549473eb23336ff27714dc918aeec22d12a5d694"
    sha256 cellar: :any,                 x86_64_linux:      "98af1c492826e9c822d5735be4e0ddc830d80ed96e7402b8c1705dc31ba3f3fb"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/chainloop-dev/chainloop/app/cli/cmd.Version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"chainloop"), "./app/cli"

    generate_completions_from_executable(bin/"chainloop", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/chainloop version 2>&1")

    output = shell_output("#{bin}/chainloop artifact download 2>&1", 1)
    assert_match "chainloop auth login", output
  end
end
