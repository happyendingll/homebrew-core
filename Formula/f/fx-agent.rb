class FxAgent < Formula
  desc "Tiny, open, embeddable, native coding agent"
  homepage "https://fx.sh"
  url "https://github.com/vercel-labs/fx/archive/refs/tags/v0.0.16.tar.gz"
  sha256 "545d95702ad2a0ce811af9261b7fe2daa1a4e6394ff6de54f4020e419d333079"
  license "Apache-2.0"
  head "https://github.com/vercel-labs/fx.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "9aa67dfd749fef41839316441b6b3b0d1bf224aed22e6a8ea6d47e717724e8e2"
  end

  depends_on "zig" => :build

  conflicts_with "fx", because: "both install an `fx` binary"

  deny_network_access!

  def install
    system "zig", "build", *std_zig_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fx --version")

    output = shell_output("#{bin}/fx ask hello 2>&1", 1)
    assert_match "fx needs access to Vercel AI Gateway", output
  end
end
