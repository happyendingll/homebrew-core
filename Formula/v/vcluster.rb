class Vcluster < Formula
  desc "Creates fully functional virtual k8s cluster inside host k8s cluster's namespace"
  homepage "https://www.vcluster.com"
  url "https://github.com/loft-sh/vcluster/archive/refs/tags/v0.37.5.tar.gz"
  sha256 "0c6fd72a8d1b4e5a8249ef76c653fecb127876f4edf447699dbc1d674c2f2928"
  license "Apache-2.0"
  head "https://github.com/loft-sh/vcluster.git", branch: "main"

  # Upstream creates releases that use a stable tag (e.g., `v1.2.3`) but are
  # labeled as "pre-release" on GitHub before the version is released, so it's
  # necessary to use the `GithubLatest` strategy.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "ddcf6b9b28c29587461cb1b34f7e7fad019977384219a440dfc6333dfbd17179"
  end

  depends_on "go" => :build
  depends_on "helm"
  depends_on "kubernetes-cli"

  deny_network_access!

  def fetch
    # `go generate` downloads the disposable email domains blocklist
    system "go", "generate", "./..."
  end

  def install
    system "go", "build", "-mod", "vendor", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/vclusterctl"

    generate_completions_from_executable(bin/"vcluster", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vcluster version")

    output = shell_output("#{bin}/vcluster create vcluster -n vcluster --create-namespace 2>&1", 1)
    assert_match "try setting KUBERNETES_MASTER environment variable", output
  end
end
