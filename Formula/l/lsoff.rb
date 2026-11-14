class Lsoff < Formula
  desc "List listening TCP and UDP ports"
  homepage "https://github.com/yutat23/lsoff"
  url "https://github.com/yutat23/lsoff/archive/refs/tags/v0.1.6.tar.gz"
  sha256 "d6acf3cace6fce7d56e02c3310023fb9bebf82d8a99ff672f1c4270141c25641"
  license "MIT"
  head "https://github.com/yutat23/lsoff.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "3e992a293c545ea89becc015e4ab63599f6c93bbea8e7d347d7754546409fff8"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lsoff --version")

    output = shell_output("#{bin}/lsoff --kill 2>&1", 2)
    assert_match "-k requires a port", output
  end
end
