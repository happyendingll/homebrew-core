class Gopeed < Formula
  desc "Multi protocol download manager"
  homepage "https://gopeed.com"
  url "https://github.com/GopeedLab/gopeed/archive/refs/tags/v2.0.0.tar.gz"
  sha256 "76b15f02749276b212f9d0305e6e073de64ce078b62894202141ab0b078cb160"
  license "GPL-3.0-or-later"
  head "https://github.com/GopeedLab/gopeed.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "f32a44acf56aec3f9ec0d74da0e634d992b3ccc7edb490241cdd454a2b1fcb08"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/gopeed"
  end

  test do
    output = shell_output("#{bin}/gopeed https://example.com/")
    assert_match "saving path: #{testpath}", output
    assert_match "Example Domain", (testpath/"example.com").read
  end
end
