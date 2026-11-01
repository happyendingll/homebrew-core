class Liqoctl < Formula
  desc "Is a CLI tool to install and manage Liqo-enabled clusters"
  homepage "https://liqo.io"
  url "https://github.com/liqotech/liqo/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "a019185fb160aa93210b1701dece8571e029a089e213f8c1efeec4ebce18bb48"
  license "Apache-2.0"
  head "https://github.com/liqotech/liqo.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "baa4d4194cb761c287ac697192930e49cb3914c61461b363c522a39148e3149a"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "0"

    ldflags = %W[-X github.com/liqotech/liqo/pkg/liqoctl/version.LiqoctlVersion=v#{version}]

    system "go", "build", *std_go_args(ldflags:), "./cmd/liqoctl"

    generate_completions_from_executable(bin/"liqoctl", shell_parameter_format: :cobra)
  end

  test do
    run_output = shell_output("#{bin}/liqoctl 2>&1")
    assert_match "liqoctl is a CLI tool to install and manage Liqo.", run_output
    assert_match version.to_s, shell_output("#{bin}/liqoctl version --client")
  end
end
