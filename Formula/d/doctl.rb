class Doctl < Formula
  desc "Command-line tool for DigitalOcean"
  homepage "https://docs.digitalocean.com/reference/doctl/"
  url "https://github.com/digitalocean/doctl/archive/refs/tags/v1.171.0.tar.gz"
  sha256 "8dc3a8d33a63225fc59642c0c5debe9c8c1b90899446f7512e7c79ced761076d"
  license "Apache-2.0"
  head "https://github.com/digitalocean/doctl.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "4b2373affdc3ab114810ff27b4dadf7c1de7b19dfc8c5104832bac965f9133f9"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4b2373affdc3ab114810ff27b4dadf7c1de7b19dfc8c5104832bac965f9133f9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "4b2373affdc3ab114810ff27b4dadf7c1de7b19dfc8c5104832bac965f9133f9"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "512511a41f306770b6f4cf96df236fc01b0434d64755cb9548179aae9bd923cc"
    sha256 cellar: :any,                 x86_64_linux:      "47a5c89d504a738c69580902afb43b70b9014c7ac34b48918fdc259fd06b19b4"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/digitalocean/doctl.Major=#{version.major}
      -X github.com/digitalocean/doctl.Minor=#{version.minor}
      -X github.com/digitalocean/doctl.Patch=#{version.patch}
      -X github.com/digitalocean/doctl.Label=release
    ]

    system "go", "build", *std_go_args(ldflags:), "./cmd/doctl"

    generate_completions_from_executable(bin/"doctl", shell_parameter_format: :cobra)
  end

  test do
    assert_match "doctl version #{version}-release", shell_output("#{bin}/doctl version")
  end
end
