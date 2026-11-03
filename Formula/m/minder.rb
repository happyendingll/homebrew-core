class Minder < Formula
  desc "CLI for interacting with Stacklok's Minder platform"
  homepage "https://mindersec.github.io/"
  url "https://github.com/mindersec/minder/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "8369884bc19980d6caef536c0d4146d580caf89b32632c59be4354b0befdb2db"
  license "Apache-2.0"
  head "https://github.com/mindersec/minder.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "1fe7f7496fd6eb93fb5be4e1b735e810f4cf4a03b08de3270da6e0e6bac1979e"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X github.com/mindersec/minder/internal/constants.CLIVersion=#{version}]
    system "go", "build", *std_go_args(ldflags:), "./cmd/cli"

    generate_completions_from_executable(bin/"minder", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/minder version 2>&1")

    # All the cli action trigger to open github authorization page,
    # so we cannot test them directly.
  end
end
