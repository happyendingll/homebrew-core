class Dysk < Formula
  desc "Linux utility to get information on filesystems, like df but better"
  homepage "https://dystroy.org/dysk/"
  url "https://github.com/Canop/dysk/archive/refs/tags/v3.7.0.tar.gz"
  sha256 "6c53a413f9c79855824116483ebcad7b6cd3cd6d37bbf39698d37e5013b27454"
  license "MIT"
  head "https://github.com/Canop/dysk.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "00026d893ab7a5c992679c7d3770982473c35c31b0ddc0f7254df83df412d1be"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "filesystem", shell_output("#{bin}/dysk -s free-d")
    assert_match version.to_s, shell_output("#{bin}/dysk --version")
  end
end
