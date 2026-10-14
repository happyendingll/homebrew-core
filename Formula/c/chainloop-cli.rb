class ChainloopCli < Formula
  desc "CLI for interacting with Chainloop"
  homepage "https://docs.chainloop.dev"
  url "https://github.com/chainloop-dev/chainloop/archive/refs/tags/v1.122.2.tar.gz"
  sha256 "f96f11accbe28a9fbed1cd7292e9f9da98ef5c357209c5f7e0d1fe3ba2ed52e1"
  license "Apache-2.0"
  head "https://github.com/chainloop-dev/chainloop.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "3f3e9dc659686cd4e01b9f5233c39bea46344d2b734a8e19f1167fd4f65e7529"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3f3e9dc659686cd4e01b9f5233c39bea46344d2b734a8e19f1167fd4f65e7529"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "3f3e9dc659686cd4e01b9f5233c39bea46344d2b734a8e19f1167fd4f65e7529"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "3e36e3643e3ded0c384bd43d5a2d14a6da7ffd43447f782d0c2a1de81552f973"
    sha256 cellar: :any,                 x86_64_linux:      "12c68dd795fc000db19e3a421366b251d1c712b8818dbbbc4291c1b6e97b2240"
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
