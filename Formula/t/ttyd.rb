class Ttyd < Formula
  desc "Command-line tool for sharing terminal over the web"
  homepage "https://tsl0922.github.io/ttyd/"
  url "https://github.com/tsl0922/ttyd/archive/refs/tags/1.7.7.tar.gz"
  sha256 "039dd995229377caee919898b7bd54484accec3bba49c118e2d5cd6ec51e3650"
  license "MIT"
  revision 14
  head "https://github.com/tsl0922/ttyd.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 sequoia: "e58b953bf24d157d390288507b62cc18d87d49b401e3255705065d186fd596cb"
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
