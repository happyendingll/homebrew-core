class Netcode < Formula
  desc "Secure client/server protocol for multiplayer games built on top of UDP"
  homepage "https://github.com/mas-bandwidth/netcode"
  url "https://github.com/mas-bandwidth/netcode/archive/refs/tags/v1.5.0.tar.gz"
  sha256 "77399eff996ffd43f8c7bf496d7b51aa6dfc76a57055812505ef7610e554a1c5"
  license "BSD-3-Clause"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "ab8b2a28dd6b6d0b6a2afcbb7435e9c7672a3be4631a1e4df2e9aac7977da262"
  end

  depends_on "cmake" => :build
  depends_on "libsodium"

  allow_network_access! :test

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DNETCODE_SYSTEM_SODIUM=ON",
                    "-DBUILD_SHARED_LIBS=ON",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <netcode.h>

      int main(void) {
        if (netcode_init() != NETCODE_OK) return 1;
        struct netcode_address_t address;
        if (netcode_parse_address("127.0.0.1:40000", &address) != NETCODE_OK) return 1;
        if (address.port != 40000) return 1;
        struct netcode_server_config_t config;
        netcode_default_server_config(&config);
        struct netcode_server_t *server = netcode_server_create("127.0.0.1:40000", &config, 0.0);
        if (!server) return 1;
        netcode_server_start(server, 16);
        if (!netcode_server_running(server)) return 1;
        netcode_server_destroy(server);
        netcode_term();
        return 0;
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lnetcode", "-o", "test"
    system "./test"
  end
end
