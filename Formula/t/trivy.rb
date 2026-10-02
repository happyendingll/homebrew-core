class Trivy < Formula
  desc "Vulnerability scanner for container images, file systems, and Git repos"
  homepage "https://trivy.dev/"
  url "https://github.com/aquasecurity/trivy/archive/refs/tags/v0.75.0.tar.gz"
  sha256 "4ee2010384f90bf23d4059ae49c11129e5041816a3754d890a90ae80f678d765"
  license "Apache-2.0"
  compatibility_version 1
  head "https://github.com/aquasecurity/trivy.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "27f6ff02a2d134eb30085e3e75f5a1bdf3ce51202f4f719e9c3aeacf5c68a603"
  end

  depends_on "go" => :build

  # `test do` block downloads a container image and the vulnerability DB
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["GOEXPERIMENT"] = "jsonv2"

    ldflags = %W[-X github.com/aquasecurity/trivy/pkg/version/app.ver=#{version}]
    system "go", "build", *std_go_args(ldflags:), "./cmd/trivy"
    (pkgshare/"templates").install Dir["contrib/*.tpl"]

    generate_completions_from_executable(bin/"trivy", shell_parameter_format: :cobra)
  end

  test do
    output = shell_output("#{bin}/trivy image alpine:3.10")
    assert_match(/\(UNKNOWN: \d+, LOW: \d+, MEDIUM: \d+, HIGH: \d+, CRITICAL: \d+\)/, output)

    assert_match version.to_s, shell_output("#{bin}/trivy --version")
  end
end
