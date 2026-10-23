class Zot < Formula
  desc "Lightweight coding agent harness written in Go"
  homepage "https://www.zot.sh/"
  url "https://github.com/patriceckhart/zot/archive/refs/tags/v0.4.42.tar.gz"
  sha256 "8fee40dc5c14e58c17b0e54284cf025ed14df39e16ba9db773f3c7cea949fa15"
  license "MIT"
  head "https://github.com/patriceckhart/zot.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "73974fba86ec8eb168c1a746f52d2b57ac167e5664e3cfa09aa65b3f9576b99a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "73974fba86ec8eb168c1a746f52d2b57ac167e5664e3cfa09aa65b3f9576b99a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "73974fba86ec8eb168c1a746f52d2b57ac167e5664e3cfa09aa65b3f9576b99a"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "a17b12c8c68991edf58129d107c9680bc2ccafa26a30169925d34c25511ffe35"
    sha256 cellar: :any,                 x86_64_linux:      "b5f24c269c0cef0ae25c6be673577d8a4f3c1768583e46fe9ba75d1e3167920c"
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
