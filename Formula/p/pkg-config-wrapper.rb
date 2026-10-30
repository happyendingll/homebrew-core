class PkgConfigWrapper < Formula
  desc "Easier way to include C code in your Go program"
  homepage "https://github.com/influxdata/pkg-config"
  url "https://github.com/influxdata/pkg-config/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "11776c4f44b4d338619723cba1a6ef716573e80a358b0943ff2e2a86129ca8d5"
  license "MIT"
  compatibility_version 1
  head "https://github.com/influxdata/pkg-config.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "8ab40b919f8454d37ce1607d8636ef02e2849fe8f1afa5989f0337112dce7d3f"
  end

  depends_on "go" => :build
  depends_on "pkgconf"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args
  end

  test do
    assert_match "Found pkg-config executable", shell_output("#{bin}/pkg-config-wrapper 2>&1", 1)
  end
end
