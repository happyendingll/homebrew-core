class NetworkDoctor < Formula
  desc "Network troubleshooting TUI"
  homepage "https://github.com/heymaikol/network-doctor/"
  url "https://github.com/heymaikol/network-doctor/archive/refs/tags/v1.17.6.tar.gz"
  sha256 "c8dc09d875624288b350c14d83df6d2b750ad8fea42deab1717190c766d8f9ed"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "ffcd0e2f4e657727a1ca51d37aa2a1e3e4687ef515f6d6ce24c2eda8ceaca78f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "ffcd0e2f4e657727a1ca51d37aa2a1e3e4687ef515f6d6ce24c2eda8ceaca78f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "ffcd0e2f4e657727a1ca51d37aa2a1e3e4687ef515f6d6ce24c2eda8ceaca78f"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "58f1f0c0ee8f2a859aba447f1b5eb4ec533ade3b5f8656f872039b6140ff58ed"
    sha256 cellar: :any,                 x86_64_linux:      "8bb6c02b596a72f21707a35ccbfce0f3a07aba8a871b49880c00aa89e33705a5"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}", output: bin/"netdoc")
  end

  test do
    output = JSON.parse shell_output("#{bin}/netdoc -json")
    assert_equal version.to_s, output["version"]
    assert_equal true, output["checks"].any? { |hash| hash["id"] == "iface" && hash["status"] == "PASS" }
  end
end
