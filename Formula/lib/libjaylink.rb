class Libjaylink < Formula
  desc "Provide interoperability with JLINK hardware"
  homepage "https://gitlab.zapb.de/libjaylink/libjaylink"
  url "https://gitlab.zapb.de/libjaylink/libjaylink/-/archive/0.5.0/libjaylink-0.5.0.tar.bz2"
  sha256 "6c03a9c4d9d781c41ca0f5203e46bebe47ecd5857c6a7d75cbc52accc7be73f8"
  license "GPL-2.0-or-later"
  head "https://gitlab.zapb.de/libjaylink/libjaylink.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "620f37012ddeffa63361a1038ff29275f1ac60a0e20ece8fee1282f16018800f"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build

  depends_on "libusb"

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~CSRC
      #include <stdio.h>
      #include "libjaylink/libjaylink.h"

      int main(void)
      {
        printf("%d.%d.%d",
               jaylink_version_package_get_major(),
               jaylink_version_package_get_minor(),
               jaylink_version_package_get_micro());
        return 0;
      }
    CSRC
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-ljaylink", "-o", "test"
    system "./test"
  end
end
