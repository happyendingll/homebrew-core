class IpinfoCli < Formula
  desc "Official CLI for the IPinfo IP Address API"
  homepage "https://ipinfo.io/"
  url "https://github.com/ipinfo/cli/archive/refs/tags/ipinfo-3.3.3.tar.gz"
  sha256 "6227811eb7eb8da2931f66b1d4fe52e664610a101246ca6340a66a02723bce5d"
  license "Apache-2.0"
  head "https://github.com/ipinfo/cli.git", branch: "master"

  livecheck do
    url :stable
    regex(/^ipinfo[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "f5d4583b26c2fdc343c45c0dfc137e49cb75006f59c8a7b716e5f035f496e771"
  end

  depends_on "go" => :build

  conflicts_with "ipinfo", because: "ipinfo and ipinfo-cli install the same binaries"

  deny_network_access!

  def install
    system "./ipinfo/build.sh"
    bin.install "build/ipinfo"
    generate_completions_from_executable(bin/"ipinfo", shell_parameter_format: :cobra)
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/ipinfo version").chomp
    assert_equal "1.1.1.0\n1.1.1.1\n1.1.1.2\n1.1.1.3\n", `#{bin}/ipinfo prips 1.1.1.1/30`
  end
end
