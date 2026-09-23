class Groestlcoin < Formula
  desc "Decentralized, peer to peer payment network"
  homepage "https://www.groestlcoin.org/groestlcoin-core-wallet/"
  license "MIT"
  revision 2
  head "https://github.com/groestlcoin/groestlcoin.git", branch: "master"

  stable do
    url "https://github.com/Groestlcoin/groestlcoin/releases/download/v31.0/groestlcoin-31.0.tar.gz"
    sha256 "9c8b3004f7ed640a24acdadccace49ea123feae66ba562ca967de4119f061be3"

    # Backport for newer Boost
    patch do
      url "https://github.com/Groestlcoin/groestlcoin/commit/0bc9d354dfd8074d1c36a891a69b6585a8775c65.patch?full_index=1"
      sha256 "3f163d9775d4f80e559c28bd5a0c58586b25cb9fe08ec9340d5950355476b477"
      type :backport
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "ad6d43cc0a7698c7ac4dc537dedf8dd2f52c38ff1365f85f206fa7c20069b2e4"
  end

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "capnp"
  depends_on "libevent"
  depends_on "zeromq"

  uses_from_macos "sqlite"

  on_linux do
    depends_on "util-linux" => :build # for `hexdump`
  end

  fails_with :gcc do
    version "7" # fails with GCC 7.x and earlier
    cause "Requires std::filesystem support"
  end

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", "-DWITH_ZMQ=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    pkgshare.install "share/rpcauth"
  end

  service do
    run opt_bin/"groestlcoind"
  end

  test do
    system bin/"groestlcoin-tx", "-txid", "0100000001000000000000000000000000000000000000000000000000000" \
                                          "0000000000000ffffffff0a510101062f503253482fffffffff0100002cd6" \
                                          "e2150000232103e26025c37d6d0d968c9dabcc53b029926c3a1f9709df97c" \
                                          "11a8be57d3fa0599cac00000000"
  end
end
