class ChainloopCli < Formula
  desc "CLI for interacting with Chainloop"
  homepage "https://docs.chainloop.dev"
  url "https://github.com/chainloop-dev/chainloop/archive/refs/tags/v1.127.0.tar.gz"
  sha256 "87c35f0261397df4ebebe23feff3edcff23b7e9e2c5a94b6f9d91ad1444de036"
  license "Apache-2.0"
  head "https://github.com/chainloop-dev/chainloop.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "9a38101756e2830bd8e77d521a76a3b4b13b5e3a74ff06b05b610c7af3591631"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "9a38101756e2830bd8e77d521a76a3b4b13b5e3a74ff06b05b610c7af3591631"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "9a38101756e2830bd8e77d521a76a3b4b13b5e3a74ff06b05b610c7af3591631"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "386cc704a912b34545e00650401e622f3bcf904cfc8d7846ca8322042eb83546"
    sha256 cellar: :any,                 x86_64_linux:      "86750b9faeaeeaec01536ca618679406f58a00a04c32c2c31cbccf01d250e0ad"
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
