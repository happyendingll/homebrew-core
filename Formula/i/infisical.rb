class Infisical < Formula
  desc "CLI for Infisical"
  homepage "https://infisical.com/docs/cli/overview"
  url "https://github.com/Infisical/cli/archive/refs/tags/v0.44.8.tar.gz"
  sha256 "de091f17331a6acfb517cf152b28d79f59ea165b269efaa702111a0bb58789aa"
  license "MIT"
  head "https://github.com/Infisical/cli.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "de3772fa4941fe07cdcd4b04f647178d018544526f05cac3f6db3d0ca0642725"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "de3772fa4941fe07cdcd4b04f647178d018544526f05cac3f6db3d0ca0642725"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "de3772fa4941fe07cdcd4b04f647178d018544526f05cac3f6db3d0ca0642725"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "240432917336b2477058a434184a99b0d3dd1f76f99cd75e2f9842eabc08b1ec"
    sha256 cellar: :any,                 x86_64_linux:      "df3ecb085555769eb1847066a616c8efc6acedb92f157d3fc3f7a4f467496212"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X github.com/Infisical/infisical-merge/packages/util.CLI_VERSION=#{version}]
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"infisical", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/infisical --version")

    output = shell_output("#{bin}/infisical reset")
    assert_match "Reset successful", output

    output = shell_output("#{bin}/infisical agent 2>&1")
    assert_match "starting Infisical agent", output
  end
end
