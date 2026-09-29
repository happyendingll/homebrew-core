class ChainloopCli < Formula
  desc "CLI for interacting with Chainloop"
  homepage "https://docs.chainloop.dev"
  url "https://github.com/chainloop-dev/chainloop/archive/refs/tags/v1.111.2.tar.gz"
  sha256 "01ae31e397aa328923b2e0944dcded2a98a48a7fa70cd62df964c5a141713f7d"
  license "Apache-2.0"
  head "https://github.com/chainloop-dev/chainloop.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e6bad48dbc81f5bbb1a3e30980b58ca97e1c1ac37468a72e56bd675e2f4ebe41"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "e6bad48dbc81f5bbb1a3e30980b58ca97e1c1ac37468a72e56bd675e2f4ebe41"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "e6bad48dbc81f5bbb1a3e30980b58ca97e1c1ac37468a72e56bd675e2f4ebe41"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "26712e438f2304ae9370ae831220d06166db730fca142009cfbda857c3ce0359"
    sha256 cellar: :any,                 x86_64_linux:      "47fc9b45f11f29e3054bdd00573d5ca08555737e3494b4d25edc5b5013dac04d"
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
