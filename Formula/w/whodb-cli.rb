class WhodbCli < Formula
  desc "Database management CLI with TUI interface, MCP server support, AI, and more"
  homepage "https://whodb.com/"
  url "https://github.com/clidey/whodb/archive/refs/tags/0.134.0.tar.gz"
  sha256 "7581d72837fcfc181f0f7c6a6235429278950da6360c3ca62026b5bad2f3a1b6"
  license "Apache-2.0"
  head "https://github.com/clidey/whodb.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "03a6fcc4e08db5aff987ea2619bc27fd1ecf8dccb36794d974cdaaba0578ab71"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    baml_version = File.read("core/go.mod")[%r{github\.com/boundaryml/baml\s+v?([\d.]+)}, 1]
    ldflags = %W[
      -X github.com/clidey/whodb/cli/pkg/version.Version=#{version}
      -X github.com/clidey/whodb/cli/pkg/version.Commit=#{tap.user}
      -X github.com/clidey/whodb/cli/pkg/version.BuildDate=#{time.iso8601}
      -X github.com/clidey/whodb/cli/internal/baml.BAMLVersion=#{baml_version}
    ]

    system "go", "build", *std_go_args(output: bin/"whodb", ldflags:), "./cli"
    bin.install_symlink bin/"whodb" => "whodb-cli"

    generate_completions_from_executable(bin/"whodb", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/whodb version")

    output = shell_output("#{bin}/whodb connections list --format json")
    assert_kind_of Array, JSON.parse(output)
  end
end
