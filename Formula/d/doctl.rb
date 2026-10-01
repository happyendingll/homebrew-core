class Doctl < Formula
  desc "Command-line tool for DigitalOcean"
  homepage "https://docs.digitalocean.com/reference/doctl/"
  url "https://github.com/digitalocean/doctl/archive/refs/tags/v1.176.0.tar.gz"
  sha256 "5d5d1671cc8abf76b1b49114835268fa1738e50e39c7de8c55dc3ffeb1887fbd"
  license "Apache-2.0"
  head "https://github.com/digitalocean/doctl.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "7f3d1890ac148bd06c5ed91879fb093969b2544993236d6dc32054b324a91b64"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "7f3d1890ac148bd06c5ed91879fb093969b2544993236d6dc32054b324a91b64"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "7f3d1890ac148bd06c5ed91879fb093969b2544993236d6dc32054b324a91b64"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "955324829c5eefb686300ad6f2d4ebd3ff1d48043c843dd354fa2fb80edd3017"
    sha256 cellar: :any,                 x86_64_linux:      "43dfe2df53de7ba129bec507c979c47ff12d0d5941bf5852821218bbe22f2e2e"
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
