class ChainloopCli < Formula
  desc "CLI for interacting with Chainloop"
  homepage "https://docs.chainloop.dev"
  url "https://github.com/chainloop-dev/chainloop/archive/refs/tags/v1.124.0.tar.gz"
  sha256 "07a3d5fa1961907c759bb6d9c75bc33a04270f42fe324b9d24da1a6fd829a49b"
  license "Apache-2.0"
  head "https://github.com/chainloop-dev/chainloop.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "ed657cda974e3b83ac195c68e7261fe4a54a14d5001912e03d31095a0a53a25c"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "ed657cda974e3b83ac195c68e7261fe4a54a14d5001912e03d31095a0a53a25c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "ed657cda974e3b83ac195c68e7261fe4a54a14d5001912e03d31095a0a53a25c"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "ac1101c6aeac70006ffaed00b65d06f1579a71a4b29bfdb19017a2a75c39c114"
    sha256 cellar: :any,                 x86_64_linux:      "493c78bd34fd268ae6df981ceeb2e24afbfbf8a916183de303c311f3ea2266f8"
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
