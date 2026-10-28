class FxAgent < Formula
  desc "Tiny, open, embeddable, native coding agent"
  homepage "https://fx.sh"
  url "https://github.com/vercel-labs/fx/archive/refs/tags/v0.0.15.tar.gz"
  sha256 "1358cafff78bb6375fab5a5216235eafdde84057e84cc122d841a920af3d1361"
  license "Apache-2.0"
  head "https://github.com/vercel-labs/fx.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "49f0c87ff1f234af085786cb921b2ee9cebeca76f7339e81a3a1cfabfc141e57"
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
