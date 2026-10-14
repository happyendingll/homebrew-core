class Doctl < Formula
  desc "Command-line tool for DigitalOcean"
  homepage "https://docs.digitalocean.com/reference/doctl/"
  url "https://github.com/digitalocean/doctl/archive/refs/tags/v1.186.0.tar.gz"
  sha256 "c148c8d8d5ff42ce147a4bd7ccfc4e06b8ecfc337b33c41f2a2ce1f0578533a7"
  license "Apache-2.0"
  head "https://github.com/digitalocean/doctl.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e5513dfd4beea9d98ebd2d5babe46cf917ad08866918a5223ae2b7af0d8f7871"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "e5513dfd4beea9d98ebd2d5babe46cf917ad08866918a5223ae2b7af0d8f7871"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "e5513dfd4beea9d98ebd2d5babe46cf917ad08866918a5223ae2b7af0d8f7871"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "dff9aeec2b908cbcd5489955a8bffa4919281f22ce2b3173bf61ab8608f62a5a"
    sha256 cellar: :any,                 x86_64_linux:      "b608a4987c31a21e641283fbf76dabc060c3d542334c66ce448e8f3340655c5a"
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
