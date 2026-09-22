class Abpoa < Formula
  desc "SIMD-based C library for fast partial order alignment using adaptive band"
  homepage "https://github.com/yangao07/abPOA"
  url "https://github.com/yangao07/abPOA/releases/download/v1.5.7/abPOA-v1.5.7.tar.gz"
  sha256 "9c5e7649a4268223ef1fec0318b3f4fa7c118ffa2daac124051c7961e6894bc8"
  license "MIT"
  head "https://github.com/yangao07/abPOA.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "1e6b142211f94c2c9cfeefde27eb04df4aab8f336a2f081e1ef1fab8a55c431b"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    system "make"
    bin.install "bin/abpoa"
    pkgshare.install "test_data"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/abpoa --version")
    cp_r pkgshare/"test_data/.", testpath
    assert_match ">Consensus_sequence", shell_output("#{bin}/abpoa seq.fa")
  end
end
