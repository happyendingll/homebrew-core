class Buildkite < Formula
  desc "Work with Buildkite from the command-line"
  homepage "https://github.com/buildkite/cli"
  url "https://github.com/buildkite/cli/archive/refs/tags/v3.65.0.tar.gz"
  sha256 "df4b7cf62080f240834d4243cfc09c8f638c00da658527f7053c61bb487491b2"
  license "MIT"
  head "https://github.com/buildkite/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "74f9404b753acad7bc625d4cf6351d7b5ce043578dd56f6d61003b782d9f0134"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-s -w -X github.com/buildkite/cli/v3/cmd/version.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "."
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/buildkite --version")

    system bin/"buildkite", "config", "set", "output_format", "yaml", "--local"
    assert_equal "yaml", shell_output("#{bin}/buildkite config get output_format").strip
  end
end
