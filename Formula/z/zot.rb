class Zot < Formula
  desc "Lightweight coding agent harness written in Go"
  homepage "https://www.zot.sh/"
  url "https://github.com/patriceckhart/zot/archive/refs/tags/v0.4.52.tar.gz"
  sha256 "6bbfddf1fc53af6820f116a67075c52fff453d6d178ca310c991dbd2b77d3df5"
  license "MIT"
  head "https://github.com/patriceckhart/zot.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "61df7688f0fc26352afb202a80f9b4b372095d03dd879614ceb6c5df981c126a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "61df7688f0fc26352afb202a80f9b4b372095d03dd879614ceb6c5df981c126a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "61df7688f0fc26352afb202a80f9b4b372095d03dd879614ceb6c5df981c126a"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "9f28948b8a2724019fa93670071f483919c02981a70a04ede27c70e32637014b"
    sha256 cellar: :any,                 x86_64_linux:      "673581d2a10e74f993fc8695014c46d34873c532d3c00c56e968b6bffcfde532"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/zot"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zot --version")
    assert_match "zot: no credential for anthropic", shell_output("#{bin}/zot rpc 2>&1", 1)
  end
end
