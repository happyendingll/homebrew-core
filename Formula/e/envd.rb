class Envd < Formula
  desc "Reproducible development environment for AI/ML"
  homepage "https://envd.tensorchord.ai"
  url "https://github.com/tensorchord/envd/archive/refs/tags/v1.3.6.tar.gz"
  sha256 "795776d46263d2a21312cd3b4eabc6d3cc19560f82b02aee1dd066045eb7b5d2"
  license "Apache-2.0"
  head "https://github.com/tensorchord/envd.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "86de2cccc18b59e698a3424326a9e057724ebcf12d2aa36b73431bb21b690980"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/tensorchord/envd/pkg/version.buildDate=#{time.iso8601}
      -X github.com/tensorchord/envd/pkg/version.version=#{version}
      -X github.com/tensorchord/envd/pkg/version.gitTag=v#{version}
      -X github.com/tensorchord/envd/pkg/version.gitCommit=#{tap.user}
      -X github.com/tensorchord/envd/pkg/version.gitTreeState=clean
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/envd"
    generate_completions_from_executable(bin/"envd", "completion", "--no-install", "--shell")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/envd version --short")

    ENV["DOCKER_HOST"] = "unix://#{testpath}/invalid.sock"
    expected = "failed to list containers: failed to connect to the docker API"
    assert_match expected, shell_output("#{bin}/envd env list 2>&1", 1)
  end
end
