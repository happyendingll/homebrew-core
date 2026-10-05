class Stlink < Formula
  desc "STM32 discovery line Linux programmer"
  homepage "https://github.com/stlink-org/stlink"
  url "https://github.com/stlink-org/stlink/archive/refs/tags/v1.9.0.tar.gz"
  sha256 "10d6c3bff3d5a7f6aefd00e096339822cafc65acf32e43c842369e346d2e5069"
  license "BSD-3-Clause"
  head "https://github.com/stlink-org/stlink.git", branch: "testing"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "b75d41e44da7af07f5d48646c92333998d21ed872c40c520b90f1abbe1f0920b"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "libusb"

  deny_network_access!

  def install
    libusb = Formula["libusb"]
    args = %W[
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DLIBUSB_INCLUDE_DIR=#{libusb.opt_include}/libusb-#{libusb.version.major_minor}
      -DLIBUSB_LIBRARY=#{libusb.opt_lib/shared_library("libusb-#{libusb.version.major_minor}")}
    ]
    if OS.linux?
      args << "-DSTLINK_MODPROBED_DIR=#{lib}/modprobe.d"
      args << "-DSTLINK_UDEV_RULES_DIR=#{lib}/udev/rules.d"
    end

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    # Upstream also installs the shared library to bin, which is only needed for Windows DLLs
    rm(bin.glob("libstlink*"))
  end

  test do
    assert_match "st-flash #{version}", shell_output("#{bin}/st-flash --debug reset 2>&1", 255)
  end
end
