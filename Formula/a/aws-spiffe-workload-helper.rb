class AwsSpiffeWorkloadHelper < Formula
  desc "Helper for providing AWS credentials to workloads using their SPIFFE identity"
  homepage "https://github.com/spiffe/aws-spiffe-workload-helper"
  url "https://github.com/spiffe/aws-spiffe-workload-helper/archive/refs/tags/v0.0.7.tar.gz"
  sha256 "9ff2c4f824dd8715e5eb5c186a9bf877887aff1b3bef153b653facbd833040ca"
  license "Apache-2.0"
  head "https://github.com/spiffe/aws-spiffe-workload-helper.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "f4e0328f7b6651b1d19f43e590352c560a10fbefc3d634dfbeb99e4c1f4ebf46"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd"

    generate_completions_from_executable(bin/"aws-spiffe-workload-helper", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aws-spiffe-workload-helper --version")

    output = shell_output("#{bin}/aws-spiffe-workload-helper jwt-credential-process " \
                          "--audience test-audience --endpoint http://localhost 2>&1", 1)
    assert_match "Error: creating workload api client: workload endpoint socket address is not configured", output
  end
end
