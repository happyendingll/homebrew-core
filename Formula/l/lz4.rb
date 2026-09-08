class Lz4 < Formula
  desc "Extremely Fast Compression algorithm"
  homepage "https://lz4.github.io/lz4/"
  url "https://github.com/lz4/lz4/archive/refs/tags/v1.10.0.tar.gz"
  mirror "http://fresh-center.net/linux/misc/lz4-1.10.0.tar.gz"
  mirror "http://fresh-center.net/linux/misc/legacy/lz4-1.10.0.tar.gz"
  sha256 "537512904744b35e232912055ccf8ec66d768639ff3abe5788d90d792ec5f48b"
  license "BSD-2-Clause"
  head "https://github.com/lz4/lz4.git", branch: "dev"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "c84d653155571488c94bf002adf7adf3a2d161c795a2c5bde77232e79a5b0629"
  end

  deny_network_access!

  def install
    system "make", "install", "PREFIX=#{prefix}"
    # Prevent dependents from hardcoding Cellar paths.
    inreplace lib/"pkgconfig/liblz4.pc", prefix, opt_prefix
  end

  test do
    input = "testing compression and decompression"
    compressed = pipe_output(bin/"lz4", input)
    refute_empty compressed
    decompressed = pipe_output("#{bin}/lz4 -d", compressed)
    assert_equal decompressed, input
  end
end
