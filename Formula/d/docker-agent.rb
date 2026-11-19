class DockerAgent < Formula
  desc "Agent Builder and Runtime by Docker Engineering"
  homepage "https://docker.github.io/docker-agent/"
  url "https://github.com/docker/docker-agent/archive/refs/tags/v1.162.0.tar.gz"
  sha256 "7cd9c017d833b7dedd055b8bff94077565d7fb999c0b02e5d6444d7d2132558a"
  license "Apache-2.0"
  head "https://github.com/docker/docker-agent.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "04847bf9b2375a00386e889a033ec0b1f4fb6abe05dbad1b1afa3fd1d3b6851d"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    ldflags = %W[
      -X github.com/docker/docker-agent/pkg/version.Version=v#{version}
      -X github.com/docker/docker-agent/pkg/version.Commit=#{tap.user}
    ]

    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"docker-agent", shell_parameter_format: :cobra)
  end

  test do
    (testpath/"agent.yaml").write <<~YAML
      version: "2"
      agents:
        root:
          model: openai/gpt-4o
    YAML

    assert_match("docker-agent version v#{version}", shell_output("#{bin}/docker-agent version"))
    output = shell_output("#{bin}/docker-agent run --exec --dry-run agent.yaml hello 2>&1", 1)
    assert_match(/must be set.*OPENAI_API_KEY/m, output)
  end
end
