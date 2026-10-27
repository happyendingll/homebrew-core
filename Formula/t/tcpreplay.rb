class Tcpreplay < Formula
  desc "Replay saved tcpdump files at arbitrary speeds"
  homepage "https://tcpreplay.appneta.com/"
  url "https://github.com/appneta/tcpreplay/releases/download/v4.6.2/tcpreplay-4.6.2.tar.gz"
  sha256 "ac4cbc58b4121edb273bc7d4603dfd6a762e7d344981233c8a253425d9dddd8f"
  license all_of: ["BSD-2-Clause", "BSD-3-Clause", "BSD-4-Clause", "GPL-3.0-or-later", "ISC"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "afbc161397825be739883e4b453f39518a51ed4ce7fec3f8b496bec75e57d0a8"
  end

  depends_on "cmake" => :build
  depends_on "libdnet"

  uses_from_macos "libpcap"

  deny_network_access!

  def install
    args = %W[-DWITH_LIBDNET=#{formula_opt_prefix("libdnet")}]
    args << "-DWITH_LIBPCAP=#{formula_opt_prefix("libpcap")}" if OS.linux?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system bin/"tcpreplay", "--version"
  end
end
