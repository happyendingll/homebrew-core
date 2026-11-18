class Hidapi < Formula
  desc "Library for communicating with USB and Bluetooth HID devices"
  homepage "https://libusb.info/hidapi/"
  url "https://github.com/libusb/hidapi/archive/refs/tags/hidapi-0.16.0.tar.gz"
  sha256 "bc599d295792fe515778f19ce86a49760b0ea5fc114e5258245d470609632bbf"
  license any_of: ["GPL-3.0-only", "BSD-3-Clause", "HIDAPI"]
  compatibility_version 1
  head "https://github.com/libusb/hidapi.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "bbd193aceed81a244c7679f958ada841b1a0b38d2a9046c46c3a72b0be18edf0"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  on_linux do
    depends_on "libusb"
    depends_on "systemd" # for libudev
  end

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DHIDAPI_BUILD_HIDTEST=ON",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include "hidapi.h"
      int main(void)
      {
        return hid_exit();
      }
    C

    flags = ["-I#{include}/hidapi", "-L#{lib}"]
    flags << if OS.mac?
      "-lhidapi"
    else
      "-lhidapi-hidraw"
    end
    flags += ENV.cflags.to_s.split
    system ENV.cc, "-o", "test", "test.c", *flags
    system "./test"
  end
end
