class Kubeone < Formula
  desc "Automate cluster operations on all your environments"
  homepage "https://kubeone.io"
  url "https://github.com/kubermatic/kubeone/archive/refs/tags/v1.15.0.tar.gz"
  sha256 "f7614214f85da4c652e1aa6882ae9e1edae8d6d558e7eb93306dc37c2c5515c2"
  license "Apache-2.0"
  head "https://github.com/kubermatic/kubeone.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "572685f1e9b74eba35b3fe0690d179329faa4f5b273b8346c877d299d0d9e2cc"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X k8c.io/kubeone/pkg/cmd.version=#{version}
      -X k8c.io/kubeone/pkg/cmd.date=#{time.iso8601}
    ]

    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"kubeone", "completion")
  end

  test do
    test_config = testpath/"kubeone.yaml"

    test_config.write <<~YAML
      apiVersion: kubeone.k8c.io/v1beta2
      kind: KubeOneCluster

      versions:
        kubernetes: 1.30.1
    YAML

    assert_match "apiEndpoint.port must be greater than 0", shell_output("#{bin}/kubeone status 2>&1", 15)

    assert_match version.to_s, shell_output("#{bin}/kubeone version")
  end
end
