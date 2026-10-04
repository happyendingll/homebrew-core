class Pvetui < Formula
  desc "Terminal UI for Proxmox VE"
  homepage "https://pvetui.org"
  url "https://github.com/devnullvoid/pvetui/releases/download/v1.4.4/pvetui_1.4.4_source.tar.gz"
  sha256 "08e41536f1185d8900de20e74d7c2ca10e92ee6136d8fc1640c4dce816f3d022"
  license "MIT"
  head "https://github.com/devnullvoid/pvetui.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "656c055cf8cdadbc1f830742de438284d222de9f0270da659d18ea1c930035a1"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/devnullvoid/pvetui/internal/version.version=#{version}
      -X github.com/devnullvoid/pvetui/internal/version.commit=#{tap.user}
      -X github.com/devnullvoid/pvetui/internal/version.buildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/pvetui"
  end

  test do
    assert_match "It looks like this is your first time running pvetui.", pipe_output(bin/"pvetui", "n")
    assert_match version.to_s, shell_output("#{bin}/pvetui --version")
  end
end
