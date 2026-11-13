class Pvetui < Formula
  desc "Terminal UI for Proxmox VE"
  homepage "https://pvetui.org"
  url "https://github.com/devnullvoid/pvetui/releases/download/v1.4.5/pvetui_1.4.5_source.tar.gz"
  sha256 "1cd5ead5cb9f2ed1177044cef7e22f7766f393e6f02adc0f19d841d62e546709"
  license "MIT"
  head "https://github.com/devnullvoid/pvetui.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "a4a40f97aea608a9f7eb0545237a854621f0606b162257d78b200dc35bb11cb5"
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
