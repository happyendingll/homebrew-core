class Zot < Formula
  desc "Lightweight coding agent harness written in Go"
  homepage "https://www.zot.sh/"
  url "https://github.com/patriceckhart/zot/archive/refs/tags/v0.3.77.tar.gz"
  sha256 "0be71342df4b94604355e370d47cef126f98d2bdade92b402d3efdc483405779"
  license "MIT"
  head "https://github.com/patriceckhart/zot.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "00d3abf3d5aac03c31567a9d70a2fb10b08d8e4b3634f422d14ed860370ef598"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "00d3abf3d5aac03c31567a9d70a2fb10b08d8e4b3634f422d14ed860370ef598"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "00d3abf3d5aac03c31567a9d70a2fb10b08d8e4b3634f422d14ed860370ef598"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "d48bce82cbfc2ee190e04ab7cb80b8bdb3f5884ed954c002916407bb91443766"
    sha256 cellar: :any,                 x86_64_linux:      "7927dc4929b63392b9b24255aca18d25cb96af867c7d4eca9f6ec6be45fc34fa"
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
