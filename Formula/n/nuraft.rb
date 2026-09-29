class Nuraft < Formula
  desc "C++ implementation of Raft core logic as a replication library"
  homepage "https://github.com/eBay/NuRaft"
  url "https://github.com/eBay/NuRaft/archive/refs/tags/v3.0.0.tar.gz"
  sha256 "073c3b321efec9ce6b2bc487c283e493a1b2dd41082c5e9ac0b8f00f9b73832d"
  license "Apache-2.0"
  revision 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "800daf3ec2847fe8b0e17ac2f7fd92a6341985f34428f7c3801c4c97e2968a51"
  end

  depends_on "cmake" => :build

  depends_on "asio"
  depends_on "openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  allow_network_access! :test

  def install
    # Avoid statically linking to OpenSSL
    inreplace "CMakeLists.txt", "set(OPENSSL_USE_STATIC_LIBS TRUE)", ""

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    pkgshare.install "examples"
  end

  test do
    cp_r pkgshare/"examples/.", testpath
    system ENV.cxx, "-std=c++11", "-o", "test",
                    "quick_start.cxx", "logger.cc", "in_memory_log_store.cxx",
                    "-I#{include}/libnuraft", "-I#{testpath}/echo",
                    "-I#{formula_opt_include("openssl@4")}",
                    "-L#{lib}", "-lnuraft",
                    "-L#{formula_opt_lib("openssl@4")}", "-lcrypto", "-lssl"
    assert_match "hello world", shell_output("./test")
  end
end
