class Tcpreplay < Formula
  desc "Replay saved tcpdump files at arbitrary speeds"
  homepage "https://tcpreplay.appneta.com/"
  url "https://github.com/appneta/tcpreplay/archive/refs/tags/v4.6.4.tar.gz"
  sha256 "e6aa11c8b948f1a9e4b682d9f083a6f4874b4269a37ef09151f76634f726e400"
  license all_of: ["BSD-2-Clause", "BSD-3-Clause", "BSD-4-Clause", "GPL-3.0-or-later", "ISC"]
  head "https://github.com/appneta/tcpreplay.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "092b656bf1b61412d9861b9af47ba8a445464e3ad7b624a3ebc96ba243aa9c21"
  end

  depends_on "cmake" => :build
  depends_on "libdnet"

  uses_from_macos "python" => :build
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
