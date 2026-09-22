class Nemu < Formula
  desc "Ncurses UI for QEMU"
  homepage "https://github.com/nemuTUI/nemu"
  url "https://github.com/nemuTUI/nemu/archive/refs/tags/v3.5.0.tar.gz"
  sha256 "dc251c6c478d60734a964324c028904e9da97dfeded7e5c6855f65e594e9a065"
  license "BSD-2-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "e474bf4e20189c5d4530abde4228aaa80424d0e1515de7c4c89db39a4e1c0917"
  end

  depends_on "cmake" => :build
  depends_on "gettext" => :build
  depends_on "pkgconf" => :build
  depends_on "json-c"
  depends_on "libarchive"
  depends_on "ncurses"
  depends_on "openssl@3"

  uses_from_macos "libxml2"
  uses_from_macos "sqlite"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "libusb"
  end

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    expected = /^Config file .* is not found.*$/
    assert_match expected, pipe_output("XDG_CONFIG_HOME=#{Dir.home} #{bin}/nemu --list", "n")
  end
end
