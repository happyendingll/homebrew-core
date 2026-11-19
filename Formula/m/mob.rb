class Mob < Formula
  desc "Tool for smooth Git handover in mob programming sessions"
  homepage "https://mob.sh"
  url "https://github.com/remotemobprogramming/mob/archive/refs/tags/v5.4.4.tar.gz"
  sha256 "1a55de8b278885b57347e3cadcb498b5d24b83f6e8299d867782294586b6b91a"
  license "MIT"
  head "https://github.com/remotemobprogramming/mob.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "4d06c73e08000d521c088122d3b27531a8b47fcbd82653f3d79aab17ce11018f"
  end

  depends_on "go" => :build

  deny_network_access!

  def install
    system "go", "build", *std_go_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mob version")
    assert_match "MOB_CLI_NAME=\"mob\"", shell_output("#{bin}/mob config")
  end
end
