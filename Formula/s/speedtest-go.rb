class SpeedtestGo < Formula
  desc "CLI and Go API to Test Internet Speed using speedtest.net"
  homepage "https://github.com/showwin/speedtest-go"
  url "https://github.com/showwin/speedtest-go/archive/refs/tags/v1.8.3.tar.gz"
  sha256 "48d01137468da9d419a3940a652803dafd8a6820abcd985b85c9d0c86b417ba3"
  license "MIT"
  head "https://github.com/showwin/speedtest-go.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "9eec5927ddedbc400c2169478b947c332a608143cb90e6e9b824310e72141446"
  end

  depends_on "go" => :build

  conflicts_with "speedtest-cli", because: "both install `speedtest` binaries"

  def install
    system "go", "build", *std_go_args(output: bin/"speedtest")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/speedtest --version 2>&1")

    assert_match "Available city labels", shell_output("#{bin}/speedtest --city-list").to_s
  end
end
