class PolicyEngine < Formula
  desc "Unified Policy Engine"
  homepage "https://github.com/snyk/policy-engine"
  url "https://github.com/snyk/policy-engine/archive/refs/tags/v1.1.8.tar.gz"
  sha256 "20df2dbcc8431835568bf97917e818596dcc0cc803f56636743f188fc7a93ac4"
  license "Apache-2.0"
  head "https://github.com/snyk/policy-engine.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "aee38732eafa256b13e20d560f01b12627c4560586c4e03336df2b8b904a93a2"
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
