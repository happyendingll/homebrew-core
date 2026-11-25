class Pscale < Formula
  desc "CLI for PlanetScale Database"
  homepage "https://www.planetscale.com/"
  url "https://github.com/planetscale/cli/archive/refs/tags/v0.357.0.tar.gz"
  sha256 "d77ffaf1a517266b936a882dc6eba8551aa27780b18e40ec70234bb4bcd4bce2"
  license "Apache-2.0"
  head "https://github.com/planetscale/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "604b6c7c1b68e54905fb8dd7eae8c3c2766fb57b7a4edc66165554160454457c"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/pscale"

    generate_completions_from_executable(bin/"pscale", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pscale version")

    assert_match "Error: not authenticated yet", shell_output("#{bin}/pscale org list 2>&1", 2)
  end
end
