class Scorecard < Formula
  desc "Security health metrics for Open Source"
  homepage "https://scorecard.dev"
  url "https://github.com/ossf/scorecard.git",
      tag:      "v5.7.0",
      revision: "d7552fb3cdc05e9f6426177d3328887304fce554"
  license "Apache-2.0"
  head "https://github.com/ossf/scorecard.git", branch: "main"

  # Upstream creates releases that use a stable tag (e.g., `v1.2.3`) but are
  # labeled as "pre-release" on GitHub before the version is released, so it's
  # necessary to use the `GithubLatest` strategy.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "c3c3ce27ea6c8d288a5890c33a9a11d38d97eff1f910280c614b42f1fa5160e2"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    pkg = "sigs.k8s.io/release-utils/version"
    ldflags = %W[
      -X #{pkg}.gitVersion=#{version}
      -X #{pkg}.gitCommit=#{Utils.git_head}
      -X #{pkg}.gitTreeState=clean
      -X #{pkg}.buildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:)
    system "make", "generate-docs"
    doc.install "docs/checks.md"

    generate_completions_from_executable(bin/"scorecard", shell_parameter_format: :cobra)
  end

  test do
    ENV["GITHUB_AUTH_TOKEN"] = "test"
    output = shell_output("#{bin}/scorecard --repo=github.com/kubernetes/kubernetes --checks=Maintained 2>&1", 1)
    expected_output = "repo unreachable: GET https://api.github.com/repos/kubernetes/kubernetes"
    assert_match expected_output, output

    assert_match version.to_s, shell_output("#{bin}/scorecard version")
  end
end
