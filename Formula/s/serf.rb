class Serf < Formula
  desc "Service orchestration and management tool"
  homepage "https://github.com/hashicorp/serf"
  url "https://github.com/hashicorp/serf/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "9b1705247d0e325d4050b79fb4ef05db899095d20ffbbf72f23161df6fd91143"
  license "MPL-2.0"
  head "https://github.com/hashicorp/serf.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "eb000cea1db0e7b8421a01e4d0992b5a7c38a7ddebe46acb95798eaf99580964"
  end

  depends_on "go" => :build

  uses_from_macos "zip" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/hashicorp/serf/version.Version=#{version}
      -X github.com/hashicorp/serf/version.VersionPrerelease=
    ]

    system "go", "build", *std_go_args(ldflags:), "./cmd/serf"
  end

  test do
    pid = spawn bin/"serf", "agent"
    sleep 1
    assert_match(/:7946.*alive$/, shell_output("#{bin}/serf members"))
  ensure
    system bin/"serf", "leave"
    Process.kill "SIGINT", pid
    Process.wait pid
  end
end
