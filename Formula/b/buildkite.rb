class Buildkite < Formula
  desc "Work with Buildkite from the command-line"
  homepage "https://github.com/buildkite/cli"
  url "https://github.com/buildkite/cli/archive/refs/tags/v3.71.0.tar.gz"
  sha256 "9194630249fea5ccdbb75057921cdb0bb9366aa86e9743d65c18153530458553"
  license "MIT"
  head "https://github.com/buildkite/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "577f5ef9c857e3d0197497c12928e3a5ab8c1530efadee3f74c5fb7c17589813"
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
