class Infisical < Formula
  desc "CLI for Infisical"
  homepage "https://infisical.com/docs/cli/overview"
  url "https://github.com/Infisical/cli/archive/refs/tags/v0.44.5.tar.gz"
  sha256 "b88aaf8e3554bf36360914234827d9e83c9d9bcec65cb8b16534f55327766a45"
  license "MIT"
  head "https://github.com/Infisical/cli.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "42a111a68dc339565a9c4d55b69d1b3da03768fd04a125a7b69e82493e86a5f9"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "42a111a68dc339565a9c4d55b69d1b3da03768fd04a125a7b69e82493e86a5f9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "42a111a68dc339565a9c4d55b69d1b3da03768fd04a125a7b69e82493e86a5f9"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "bdbe450e3c1e9e4b5b3dd4d9023dfcaa4a8e90e13df813699881f4510363ad53"
    sha256 cellar: :any,                 x86_64_linux:      "72e58c22c69c28c3d24a34b3d0325822548a1a01560fa30744ab2d8842931d61"
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
