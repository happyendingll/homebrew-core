class Kagent < Formula
  desc "Kubernetes native framework for building AI agents"
  homepage "https://kagent.dev"
  url "https://github.com/kagent-dev/kagent/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "c7fd886082871eab0d154f2f4a90cde262c978a01379c602fdb0b0939a6f65cd"
  license "Apache-2.0"
  head "https://github.com/kagent-dev/kagent.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "22edbec1e22569eb1b1606de87800a3dfee4da97066c434d5ebc97c26c60a1a1"
  end

  depends_on "go" => :build
  depends_on "kubernetes-cli" => :test

  allow_network_access! :test

  def fetch
    system "go", "mod", "download", "-C", "go"
  end

  def install
    cd "go" do
      ldflags = %W[
        -X github.com/kagent-dev/kagent/go/core/internal/version.Version=#{version}
        -X github.com/kagent-dev/kagent/go/core/internal/version.GitCommit=#{tap.user}
        -X github.com/kagent-dev/kagent/go/core/internal/version.BuildDate=#{time.strftime("%Y-%m-%d")}
      ]
      system "go", "build", *std_go_args(ldflags:), "./core/cli/cmd/kagent"
    end

    generate_completions_from_executable(bin/"kagent", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kagent version")

    (testpath/"config.yaml").write <<~YAML
      kagent_url: http://localhost:#{free_port}
      namespace: kagent
      output_format: table
      timeout: 5m0s
    YAML

    assert_match 'unknown field "kagent_url"',
      shell_output("#{bin}/kagent config validate --config config.yaml 2>&1", 1)
  end
end
