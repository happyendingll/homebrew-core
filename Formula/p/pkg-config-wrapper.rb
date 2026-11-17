class PkgConfigWrapper < Formula
  desc "Easier way to include C code in your Go program"
  homepage "https://github.com/influxdata/pkg-config"
  url "https://github.com/influxdata/pkg-config/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "c23dc2db950ed7938d6f528ca265a9c09ebbdad74e59b90cb66ecb93fc299ab2"
  license "MIT"
  compatibility_version 1
  head "https://github.com/influxdata/pkg-config.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "298d136f074a7132c03b46c1085720c0540b7a1963af2ff20fa179fe534e811c"
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
