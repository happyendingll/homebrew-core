class NetworkDoctor < Formula
  desc "Network troubleshooting TUI"
  homepage "https://github.com/heymaikol/network-doctor/"
  url "https://github.com/heymaikol/network-doctor/archive/refs/tags/v1.17.1.tar.gz"
  sha256 "214f37a55e2b4cfd96c54e9ad3785cfb6a8f8d979c2129feae41d712789bfe4c"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "57cc0611cdd9cf7d43a0725defebbb4ed8b75e58a1173e91de687b1192b4e04d"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "57cc0611cdd9cf7d43a0725defebbb4ed8b75e58a1173e91de687b1192b4e04d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "57cc0611cdd9cf7d43a0725defebbb4ed8b75e58a1173e91de687b1192b4e04d"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "2b781d1e1856dd6d27c2cd63997a008f5432490ea7025b1c765644e1ccd9b14f"
    sha256 cellar: :any,                 x86_64_linux:      "b622ac45dfe6427c1a35191f3a94ab6d486c64571bec0c5b5f20f8b298710a76"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}", output: bin/"netdoc")
  end

  test do
    output = JSON.parse shell_output("#{bin}/netdoc -json")
    assert_equal version.to_s, output["version"]
    assert_equal true, output["checks"].any? { |hash| hash["id"] == "iface" && hash["status"] == "PASS" }
  end
end
