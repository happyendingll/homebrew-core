class Certstrap < Formula
  desc "Tools to bootstrap CAs, certificate requests, and signed certificates"
  homepage "https://github.com/square/certstrap"
  url "https://github.com/square/certstrap/archive/refs/tags/v1.4.1.tar.gz"
  sha256 "7a016b02ad2fbf6a1c6dd010561b6bfe16add5e58d039db5d9ad8fcd724657e8"
  license "Apache-2.0"
  head "https://github.com/square/certstrap.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "0b7df0fa83e6ea2574a33ad340274a93e361d5713dbad7e10b1f162646c96aaf"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
  end

  test do
    system bin/"certstrap", "init", "--common-name", "Homebrew Test CA", "--passphrase", "beerformyhorses"
  end
end
