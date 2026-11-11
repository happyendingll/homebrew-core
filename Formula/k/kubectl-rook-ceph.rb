class KubectlRookCeph < Formula
  desc "Rook plugin for Ceph management"
  homepage "https://rook.io/"
  url "https://github.com/rook/kubectl-rook-ceph/archive/refs/tags/v0.10.0.tar.gz"
  sha256 "868320447f35b54bc000200b983d82dbd58ff0966734217bab3006034e967331"
  license "Apache-2.0"
  head "https://github.com/rook/kubectl-rook-ceph.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "3c9a1e9ca63e329c441a56fc31bb112e05bd60a7bef6fdb067dd5f100447a51c"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(output: "#{bin}/kubectl-rook_ceph"), "./cmd"
  end

  test do
    assert_match <<~EOS, shell_output("#{bin}/kubectl-rook_ceph health 2>&1", 1)
      Error: invalid configuration: no configuration has been provided, \
      try setting KUBERNETES_MASTER environment variable
    EOS

    output = shell_output("#{bin}/kubectl-rook_ceph --help")
    assert_match("kubectl rook-ceph provides common management and troubleshooting tools for Ceph", output)
  end
end
