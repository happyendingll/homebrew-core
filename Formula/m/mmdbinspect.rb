class Mmdbinspect < Formula
  desc "Look up records for one or more IPs/networks in one or more .mmdb databases"
  homepage "https://github.com/maxmind/mmdbinspect"
  url "https://github.com/maxmind/mmdbinspect/archive/refs/tags/v2.1.0.tar.gz"
  sha256 "ac165806226de6d6c221b1bc8b29fda1fd6d45574acea8178c338d9716d1b604"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/maxmind/mmdbinspect.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "6e563d712a9e613e6ce3899e4eb6989225cd0207ad4a264824a11dd0ed893e04"
  end

  depends_on "go" => :build

  resource "homebrew-test-data", :test do
    url "https://raw.githubusercontent.com/maxmind/MaxMind-DB/507c17e7cf266bb47bca4922aa62071cb21f6d06/test-data/GeoIP2-City-Test.mmdb"
    sha256 "7959cc4c67576efc612f1cfdea5f459358b0d69e4be19f344417e7ba4b5e8114"
  end

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/mmdbinspect"
  end

  test do
    testpath.install resource("homebrew-test-data")

    output = shell_output("#{bin}/mmdbinspect -db GeoIP2-City-Test.mmdb 175.16.199.1")
    assert_match "Changchun", output
  end
end
