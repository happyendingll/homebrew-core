class PolicyEngine < Formula
  desc "Unified Policy Engine"
  homepage "https://github.com/snyk/policy-engine"
  url "https://github.com/snyk/policy-engine/archive/refs/tags/v1.1.5.tar.gz"
  sha256 "50bef12330c2b2fdefa21958af76f6109c4bf9ea7ff7d5b26bf3a9c60c9b727a"
  license "Apache-2.0"
  head "https://github.com/snyk/policy-engine.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "48eeebc4ee6f946310156b458d80a6850c813d66d9dfa3cba2e4c9c06b3fe56a"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/snyk/policy-engine/pkg/version.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"policy-engine", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/policy-engine version")

    (testpath/"infra/test.tf").write <<~HCL
      resource "aws_s3_bucket" "foo-bucket" {
        region        = "us-east-1"
        bucket        = "test"
        acl           = "public-read"
        force_destroy = true

        versioning {
          enabled = true
        }
      }
    HCL

    assert_match "\"rule_results\": []", shell_output("#{bin}/policy-engine run infra")
  end
end
