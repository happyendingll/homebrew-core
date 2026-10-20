class Lxc < Formula
  desc "CLI client for interacting with LXD"
  homepage "https://ubuntu.com/lxd"
  url "https://github.com/canonical/lxd/archive/refs/tags/lxd-6.10.0.tar.gz"
  sha256 "4ede1d19dc6980234e1d8d68c74b09fe5631d7cac1b69081937dca42995da994"
  license "AGPL-3.0-only"
  head "https://github.com/canonical/lxd.git", branch: "main"

  livecheck do
    url :stable
    regex(/^lxd-(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "d5831e50a03cf8d7ba022ed0912650484793b4a168e36a24ca9e9484c9b375a2"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./lxc"

    generate_completions_from_executable(bin/"lxc", shell_parameter_format: :cobra)
  end

  test do
    output = JSON.parse(shell_output("#{bin}/lxc remote list --format json"))
    assert_equal "https://cloud-images.ubuntu.com/releases/", output["ubuntu"]["Addr"]

    assert_match version.to_s, shell_output("#{bin}/lxc --version")
  end
end
