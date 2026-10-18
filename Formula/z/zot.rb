class Zot < Formula
  desc "Lightweight coding agent harness written in Go"
  homepage "https://www.zot.sh/"
  url "https://github.com/patriceckhart/zot/archive/refs/tags/v0.4.34.tar.gz"
  sha256 "cc14ab18013838cb3d842b7de4d35adfc59eec4c2b1c58b4a51430e80ecf1f78"
  license "MIT"
  head "https://github.com/patriceckhart/zot.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c1cd3f38b4490450d07276acff922174acf30ae02dbcea738ceaf519b320d824"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c1cd3f38b4490450d07276acff922174acf30ae02dbcea738ceaf519b320d824"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c1cd3f38b4490450d07276acff922174acf30ae02dbcea738ceaf519b320d824"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "b8a6814b1ab4f9c92b9cb62836fe4238bd1fd413ceca8cfad93fe63c7b1a5f18"
    sha256 cellar: :any,                 x86_64_linux:      "2442dd70eb909851b42b62924bd7e6acee7ae14c7a22e30300939bd979aae467"
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
