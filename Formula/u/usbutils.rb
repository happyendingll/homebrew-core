class Usbutils < Formula
  desc "List detailed info about USB devices"
  # Homepage for multiple Linux USB tools, 'usbutils' is one of them.
  homepage "http://www.linux-usb.org/"
  url "https://mirrors.edge.kernel.org/pub/linux/utils/usb/usbutils/usbutils-020.tar.gz"
  sha256 "fed292b2a3dce83464ce9e96e7eaf301f58b3bf0104872b6a75edac14c907ff2"
  license all_of: [
    "GPL-2.0-only",
    "GPL-2.0-or-later",
    any_of: ["GPL-2.0-only", "GPL-3.0-only"],
  ]

  livecheck do
    url "https://mirrors.edge.kernel.org/pub/linux/utils/usb/usbutils/"
    regex(/href=.*?usbutils[._-]v?(\d+(?:\.\d+)*)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "69e2ed1f28bc8a35b2e8a0380d1fdc691800ff322a2dfa393268690006426b60"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "libusb"

  on_linux do
    depends_on "systemd"
  end

  conflicts_with "lsusb", "lsusb-laniksj", because: "both provide an `lsusb` binary"

  patch do
    file "Patches/usbutils/portable.patch"
    type :unofficial
  end

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  def caveats
    <<~EOS
      usbhid-dump requires either proper code signing with com.apple.vm.device-access
      entitlement or root privilege
    EOS
  end

  test do
    assert_empty shell_output("#{bin}/lsusb -d ffff:ffff", 1)
  end
end
