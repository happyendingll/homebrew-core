class ChainloopCli < Formula
  desc "CLI for interacting with Chainloop"
  homepage "https://docs.chainloop.dev"
  url "https://github.com/chainloop-dev/chainloop/archive/refs/tags/v1.113.0.tar.gz"
  sha256 "55531788860fdc1076de7490d27d0f22a766ee445b37d7281826ccbb34618e9e"
  license "Apache-2.0"
  head "https://github.com/chainloop-dev/chainloop.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c9eae159dd1eee7af9821edbb742748fb46598d238c98d42214b23d201fb243e"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c9eae159dd1eee7af9821edbb742748fb46598d238c98d42214b23d201fb243e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c9eae159dd1eee7af9821edbb742748fb46598d238c98d42214b23d201fb243e"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "3477d37985404b2447f36644d1ac687789536fcd606d2c7944632f05c512fa0c"
    sha256 cellar: :any,                 x86_64_linux:      "439a408a33a2c221d50620d00607ce780b56fdc947db2243609192d0e5c1d454"
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
