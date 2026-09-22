class StorjUplink < Formula
  desc "Uplink CLI for the Storj network"
  homepage "https://storj.io"
  url "https://github.com/storj/storj/archive/refs/tags/v1.163.5.tar.gz"
  sha256 "45ce7f7a7c73d683bb76df20b2b9cb23c60af668db38a2cf0600350970fcf895"
  license "AGPL-3.0-only"

  # Upstream creates stable releases and marks them as "pre-release" before
  # release (though some versions have permanently remained as "pre-release"),
  # so it's necessary to check releases. However, upstream has not marked
  # recent releases as "latest", so it's necessary to check all releases.
  # NOTE: We should return to using the `GithubLatest` strategy if/when
  # upstream reliably marks stable releases as "latest" again.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "45018d75df985cbde2a789278caf924fcce5f68d905a5cd0bc458fdd3e3c3582"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "45018d75df985cbde2a789278caf924fcce5f68d905a5cd0bc458fdd3e3c3582"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "45018d75df985cbde2a789278caf924fcce5f68d905a5cd0bc458fdd3e3c3582"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "067e9a7f79a0a51ab2e56d00fca39545a37eba1632b20a418a77fb4a16041b41"
    sha256 cellar: :any,                 x86_64_linux:      "0a9974abd98e0d8a5bb528ca6909748d55b37b3a9981320d2a77ad1459be4e9c"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(output: bin/"uplink"), "./cmd/uplink"
  end

  test do
    (testpath/"config.ini").write <<~INI
      [metrics]
      addr=
    INI
    ENV["UPLINK_CONFIG_DIR"] = testpath.to_s
    ENV["UPLINK_INTERACTIVE"] = "false"
    assert_match "No accesses configured", shell_output("#{bin}/uplink ls 2>&1", 1)
  end
end
