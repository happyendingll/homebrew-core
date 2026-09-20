class Goresym < Formula
  desc "Go symbol recovery tool"
  homepage "https://github.com/mandiant/GoReSym"
  url "https://github.com/mandiant/GoReSym/archive/refs/tags/v3.4.1.tar.gz"
  sha256 "c8600ad8634aae2166f09af224ac7c257c8ee403acd42d72f6f1276e786a70e8"
  license "MIT"
  head "https://github.com/mandiant/GoReSym.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "25e51103e1574af2f57fc982843eb441e351bb7bcf730dcdcb632b95bb99bed2"
  end

  # TODO: unpin go@1.26 when goresym supports go 1.27
  # ref: https://github.com/mandiant/GoReSym/issues/90
  depends_on "go@1.26" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args
  end

  test do
    output = JSON.parse(shell_output("#{bin}/goresym '#{bin}/goresym'"))
    assert_equal output["BuildInfo"]["Main"]["Path"], "github.com/mandiant/GoReSym"
  end
end
