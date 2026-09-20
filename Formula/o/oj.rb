class Oj < Formula
  desc "JSON parser and visualization tool"
  homepage "https://github.com/ohler55/ojg"
  url "https://github.com/ohler55/ojg/archive/refs/tags/v1.28.6.tar.gz"
  sha256 "7f717bbd250ae8087d4941c9255207900e438d9b585cb05aec51419fbd5d95ff"
  license "MIT"
  head "https://github.com/ohler55/ojg.git", branch: "develop"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "fa54ce02891a30e4498eac3191eef5923fbc3435aa01e1ea90a8623a51036cc8"
  end

  depends_on "go" => :build

  deny_network_access!

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=v#{version}"), "./cmd/oj"
  end

  test do
    assert_equal "1\n", pipe_output("#{bin}/oj -z @.x", "{x:1,y:2}")
  end
end
