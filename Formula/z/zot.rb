class Zot < Formula
  desc "Lightweight coding agent harness written in Go"
  homepage "https://www.zot.sh/"
  url "https://github.com/patriceckhart/zot/archive/refs/tags/v0.4.32.tar.gz"
  sha256 "873c9be3e2a510cecd9b74a3bb8bf2437b845b5edc893f23335480b3452ef122"
  license "MIT"
  head "https://github.com/patriceckhart/zot.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "94112bbb0c2e00cea81191dd914d6397dfc8d3b5f7fac7f6082d61a4f5546cf7"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "94112bbb0c2e00cea81191dd914d6397dfc8d3b5f7fac7f6082d61a4f5546cf7"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "94112bbb0c2e00cea81191dd914d6397dfc8d3b5f7fac7f6082d61a4f5546cf7"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "c4417379ebd5946dccfd5a27b81d09131214fcf631840882dc69e05e007267dd"
    sha256 cellar: :any,                 x86_64_linux:      "0740f1c26f9e60c53b3c1d599f6583dc235c0e6ec47a1cb2b273e6164bdae60b"
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
