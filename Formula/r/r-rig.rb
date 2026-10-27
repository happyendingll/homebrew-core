class RRig < Formula
  desc "R Installation Manager"
  homepage "https://github.com/r-lib/rig"
  url "https://github.com/r-lib/rig/archive/refs/tags/v0.11.1.tar.gz"
  sha256 "e6186c4fd550f1c31323d5732c95da78e8a2f0cafcd3e505264b2ec7f5a09da2"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "6f5b72cc097bb9024fe6577f00d1017869b81c539a09cf68675457cf5dcaf663"
  end

  depends_on "rust" => :build

  conflicts_with "rig", because: "both install `rig` binary"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rig --version")
    output = shell_output("#{bin}/rig default 2>&1", 1)
    assert_match "No default R version is set", output
  end
end
