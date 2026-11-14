class GitSizer < Formula
  desc "Compute various size metrics for a Git repository"
  homepage "https://github.com/github/git-sizer"
  url "https://github.com/github/git-sizer/archive/refs/tags/v1.6.0.tar.gz"
  sha256 "2c6355a9ccdaa6bbe03fa309e087483961afefcfbf354491a419e1d5e6c1bbd1"
  license "MIT"
  head "https://github.com/github/git-sizer.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "efb3d9c41ccec4a56dee6109eb90454aa1c4c38b74ffb43fca8cc13c0c9f6c9e"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.ReleaseVersion=#{version}")
  end

  test do
    system "git", "init"
    output = shell_output(bin/"git-sizer")
    assert_match "No problems above the current threshold were found", output
  end
end
