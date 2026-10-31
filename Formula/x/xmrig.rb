class Xmrig < Formula
  desc "Monero (XMR) CPU miner"
  homepage "https://xmrig.com/"
  license "GPL-3.0-or-later"
  head "https://github.com/xmrig/xmrig.git", branch: "dev"

  stable do
    url "https://github.com/xmrig/xmrig/archive/refs/tags/v6.26.0.tar.gz"
    sha256 "5005144e78571f26586410c2b2ede2b0c72afe22f97f1708ea24cfb253c3939b"

    patch do
      url "https://github.com/xmrig/xmrig/commit/2c86216a5ce816237c923e6057c5bc9aaa5387c2.patch?full_index=1"
      sha256 "abbd10046ae5db3df2712072fc49b8569daeff68e797e2b4acd1e382257c52fe"
      type :backport
    end
  end

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "c0e8a5b61bbf5e01f3d83e4b83b754a94a17f1b8eb8c185398b3645e47184e95"
  end

  depends_on "cmake" => :build
  depends_on "hwloc"
  depends_on "libuv"
  depends_on "openssl@4"

  allow_network_access! :test

  def install
    # Use shared OpenSSL on macOS. In cmake/OpenSSL.cmake:
    # elseif (APPLE)
    #   set(OPENSSL_USE_STATIC_LIBS TRUE)
    # endif()
    inreplace "cmake/OpenSSL.cmake", "OPENSSL_USE_STATIC_LIBS TRUE", "OPENSSL_USE_STATIC_LIBS FALSE"

    # Allow using shared libuv. In cmake/FindUV.cmake:
    # find_library(UV_LIBRARY NAMES libuv.a uv libuv ...)
    inreplace "cmake/FindUV.cmake", "libuv.a", ""

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    bin.install "build/xmrig"
    pkgshare.install "src/config.json"
  end

  test do
    require "pty"
    assert_match version.to_s, shell_output("#{bin}/xmrig -V")
    test_server = "donotexist.localhost:65535"
    output = ""
    args = %W[
      --no-color
      --max-cpu-usage=1
      --print-time=1
      --threads=1
      --retries=1
      --url=#{test_server}
    ]
    PTY.spawn(bin/"xmrig", *args) do |r, _w, pid|
      sleep 5
      Process.kill("SIGINT", pid)
      begin
        r.each_line { |line| output += line }
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      end
    end

    assert_match(/POOL #1\s+#{Regexp.escape(test_server)} algo auto/, output)

    match = output.match? "#{test_server} DNS error: \"unknown node or service\""
    match ||= output.match?(/#{Regexp.escape(test_server)} (?:::1|127\.0\.0\.1) connect error: "connection refused"/)
    assert match, "Expected error message not found in output"
  end
end
