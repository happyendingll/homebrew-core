class LimaAdditionalGuestagents < Formula
  desc "Additional guest agents for Lima"
  homepage "https://lima-vm.io/"
  url "https://github.com/lima-vm/lima/archive/refs/tags/v2.2.1.tar.gz"
  sha256 "d551efb52115ba006c1052d5c929e4d3afac363c78c9cfca6975af1f85c1426a"
  license "Apache-2.0"
  head "https://github.com/lima-vm/lima.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "445dbf1d2a17679b269c9d7f973ce83b864ab664886f7a30647b7ec36f708b05"
  end

  depends_on "go" => :build
  depends_on "lima"
  depends_on "qemu"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    if build.head?
      system "make", "additional-guestagents"
    else
      # VERSION has to be explicitly specified when building from tar.gz, as it does not contain git tags
      system "make", "additional-guestagents", "VERSION=#{version}"
    end

    bin.install Dir["_output/bin/*"]
    share.install Dir["_output/share/*"]
  end

  test do
    info = JSON.parse shell_output("limactl info")
    assert_includes info["guestAgents"], "riscv64"
  end
end
