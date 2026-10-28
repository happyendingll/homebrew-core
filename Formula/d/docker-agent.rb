class DockerAgent < Formula
  desc "Agent Builder and Runtime by Docker Engineering"
  homepage "https://docker.github.io/docker-agent/"
  url "https://github.com/docker/docker-agent/archive/refs/tags/v1.153.0.tar.gz"
  sha256 "19f425bb2d375b5ffaeb4addb675518a156d8fb60cd0d417b28f816499cf05c8"
  license "Apache-2.0"
  head "https://github.com/docker/docker-agent.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "776e49fcea9c338468e18c947829b196db16e4beada14e593fae2e52aed5a87e"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f3e8e63e518d164f9a5a6930ae12430d346a016f60448226cd77dd2a3572df70"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "b2ff2bcbe79b5b81ec59b885cd1791563c91cf4f03c435c7ee5e2730d70627f5"
    sha256 cellar: :any,                 arm64_linux:       "6e2e5f87f948ecc0724805f4446fa52eaf2be86616b1003ba69489f68dfedcd7"
    sha256 cellar: :any,                 x86_64_linux:      "1a3033c3ded4e459f12485241126b40d61bffe64c4ae87245e63582baf7ab48b"
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
