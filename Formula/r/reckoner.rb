class Reckoner < Formula
  desc "Declaratively install and manage multiple Helm chart releases"
  homepage "https://github.com/FairwindsOps/reckoner"
  url "https://github.com/FairwindsOps/reckoner/archive/refs/tags/v6.3.1.tar.gz"
  sha256 "b5abed69ac46c99b105b2a80be26fd107a8f10ebc4ba957ff534c692ac201847"
  license "Apache-2.0"
  head "https://github.com/FairwindsOps/reckoner.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "896f28e47c67f1abe368c55f7545e7ec6c48d3e7915f08855ed39ca2d1a9ed45"
  end

  depends_on "go" => :build
  depends_on "helm"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X main.version=#{version} -X main.commit=#{tap.user}"
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"reckoner", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/reckoner version")

    # Basic Reckoner course file
    (testpath/"course.yaml").write <<~YAML
      schema: v2
      namespace: test
      repositories:
        stable:
          url: https://charts.helm.sh/stable
      releases:
        - name: nginx
          namespace: test
          chart: stable/nginx-ingress
          version: 1.41.3
          values:
            replicaCount: 1
    YAML

    output = shell_output("#{bin}/reckoner lint #{testpath}/course.yaml 2>&1")
    assert_match "No schema validation errors found", output
  end
end
