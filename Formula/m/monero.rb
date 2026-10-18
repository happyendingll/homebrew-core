class Monero < Formula
  desc "Official Monero wallet and CPU miner"
  homepage "https://www.getmonero.org/downloads/#cli"
  license "BSD-3-Clause"

  stable do
    url "https://downloads.getmonero.org/cli/monero-source-v0.18.5.4.tar.bz2"
    sha256 "3c5aabb6e8abcabb58169cf4ad60b11be23cd7384c051a40ed2b23490d842bab"

    # Backport support for OpenSSL 4
    patch do
      url "https://github.com/monero-project/monero/commit/4f73cfea6d37bc1eccab1e395fc526c94cbb99ba.patch?full_index=1"
      sha256 "246466b0ce14c4b6f2ec7f424ca80c08369a87950be9cafefeec6171dc05c9cb"
      type :backport
      resolves "https://github.com/monero-project/monero/pull/10908"
    end
  end

  livecheck do
    url "https://downloads.getmonero.org/cli/source"
    strategy :header_match
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "5b372abe1553fb912c0713695fcd74471e5e36b28d19c51ece7d7ca7b8497f2b"
  end

  head do
    url "https://github.com/monero-project/monero.git", branch: "master"

    depends_on "libusb" # TODO: use on stable in 0.19 (?)
    depends_on "protobuf" # TODO: use on stable in 0.19 (?)
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "boost"
  depends_on "hidapi"
  depends_on "libsodium"
  depends_on "openssl@4"
  depends_on "readline"
  depends_on "unbound"
  depends_on "zeromq"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  service do
    run [opt_bin/"monerod", "--non-interactive"]
  end

  test do
    cmd = "yes '' | #{bin}/monero-wallet-cli --restore-deterministic-wallet " \
          "--password brew-test --restore-height 1 --generate-new-wallet wallet " \
          "--electrum-seed 'baptism cousin whole exquisite bobsled fuselage left " \
          "scoop emerge puzzled diet reinvest basin feast nautical upon mullet " \
          "ponies sixteen refer enhanced maul aztec bemused basin'" \
          "--command address"
    address = "4BDtRc8Ym9wGzx8vpkQQvpejxBNVpjEmVBebBPCT4XqvMxW3YaCALFraiQibejyMAxUXB5zqn4pVgHVm3JzhP2WzVAJDpHf"
    assert_equal address, shell_output(cmd).lines.last.split[1]
  end
end
