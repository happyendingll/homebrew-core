class Lazymake < Formula
  desc "Modern TUI for Makefiles"
  homepage "https://lazymake.vercel.app/"
  url "https://github.com/rshelekhov/lazymake/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "b141ede0499a7ec41c21782d41ebc08a87a95074e9c8c8efc7007d2ebf5e8f9e"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "e0c140f3e25188a27903f82dccba1c193d92a82e7c3c91f49c73bbb58da1e6db"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/lazymake"
  end

  test do
    # lazymake is a TUI, to verify the command is working we check the help output
    assert_match "Usage:", shell_output("#{bin}/lazymake --help")
  end
end
