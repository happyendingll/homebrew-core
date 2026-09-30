class Xdelta < Formula
  desc "Binary diff, differential compression tools"
  homepage "https://github.com/jmacd/xdelta"
  url "https://github.com/jmacd/xdelta/archive/refs/tags/v3.2.1.tar.gz"
  sha256 "dc75f6a9615ac278fe00375d94241f47af4e893f11e4a9f46b4ca4e2e1f99e66"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "108231ce04d41bee2b13fd44fa342051fb2fcf593982bb0cbce5ddd889c4e710"
  end

  depends_on "cmake" => :build
  depends_on "blake3"
  depends_on "xz"

  deny_network_access!

  def install
    # Fix library target to the same as `blake3` formula.
    inreplace "xdelta3/CMakeLists.txt",
              "set(XD3_ARMOR_LIBRARIES blake3)",
              "set(XD3_ARMOR_LIBRARIES BLAKE3::blake3)"

    args = %w[
      -DXD3_BUILD_TESTS=OFF
      -DXD3_LZMA_MODE=on
      -DHOMEBREW_ALLOW_FETCHCONTENT=ON
      -DFETCHCONTENT_FULLY_DISCONNECTED=ON
      -DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS
    ]
    system "cmake", "-S", "xdelta3", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system bin/"xdelta3", "config"
  end
end
