class Ttyd < Formula
  desc "Command-line tool for sharing terminal over the web"
  homepage "https://tsl0922.github.io/ttyd/"
  url "https://github.com/tsl0922/ttyd/archive/refs/tags/1.7.7.tar.gz"
  sha256 "039dd995229377caee919898b7bd54484accec3bba49c118e2d5cd6ec51e3650"
  license "MIT"
  revision 15
  compatibility_version 1
  head "https://github.com/tsl0922/ttyd.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 sequoia: "12224908191dce096318b2f34d9fcd89abaee993276b2a01ca0a6ec942cbaeea"
  end

  depends_on "cmake" => :build
  depends_on "json-c"
  depends_on "libevent"
  depends_on "libuv"
  depends_on "libwebsockets"
  depends_on "openssl@4"

  uses_from_macos "vim" # needed for xxd

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # Run the libuv loop directly as `lws_service` only runs a single turn from libwebsockets 5.1
  patch do
    url "https://github.com/tsl0922/ttyd/commit/fddd63815631223a794f3474869d5685362d5017.patch?full_index=1"
    sha256 "7b98a6acf9df66ffeb77423ff1af75111f220065eedc4157691f59fbac9d3bf2"
    type :unofficial
    resolves "https://github.com/tsl0922/ttyd/pull/1589"
  end

  allow_network_access! :test

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DOPENSSL_ROOT_DIR=#{formula_opt_prefix("openssl@4")}",
                    "-Dlibwebsockets_DIR=#{formula_opt_lib("libwebsockets")}/cmake/libwebsockets",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    port = free_port
    fork do
      system bin/"ttyd", "--port", port.to_s, "bash"
    end
    output = shell_output("curl --silent --retry 5 --retry-connrefused http://localhost:#{port}")
    assert_match "<title>ttyd - Terminal</title>", output[..256]
  end
end
