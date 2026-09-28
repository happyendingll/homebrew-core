class Zot < Formula
  desc "Lightweight coding agent harness written in Go"
  homepage "https://www.zot.sh/"
  url "https://github.com/patriceckhart/zot/archive/refs/tags/v0.4.3.tar.gz"
  sha256 "8f80af916124bb055a7580ab98da2bffc564af8eaf48ee87623ec4d8d0248249"
  license "MIT"
  head "https://github.com/patriceckhart/zot.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "90f80ced0a760047bafafd3f0f14c5bb31152c5d03560ff21a2080ccc9f2444e"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "90f80ced0a760047bafafd3f0f14c5bb31152c5d03560ff21a2080ccc9f2444e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "90f80ced0a760047bafafd3f0f14c5bb31152c5d03560ff21a2080ccc9f2444e"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "e56f7a49c85a667935546581d2e4238dc54c28c9d0a288551744b2e252798d31"
    sha256 cellar: :any,                 x86_64_linux:      "ae4a19e73b8f9526d2352cf5f7fd242a011ccabe433f38a37bd5dd1fe93d3af0"
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
