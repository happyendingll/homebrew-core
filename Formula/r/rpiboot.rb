class Rpiboot < Formula
  desc "Raspberry Pi USB boot tool for Compute Modules"
  homepage "https://github.com/raspberrypi/usbboot"
  url "https://github.com/raspberrypi/usbboot.git",
      tag:      "20261103-150646",
      revision: "8639e9da26db78fab8c53058e10b0ff1bf253483"
  version "20261103-150646"
  license "Apache-2.0"
  head "https://github.com/raspberrypi/usbboot.git", branch: "master"

  livecheck do
    url :stable
    regex(/^(\d{8}-\d{6})$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 sequoia: "af64427ab4a36b627d0059637006325f41ca4ad8fc6ca9afdfd6d99225c5987b"
  end

  depends_on "pkgconf" => :build
  depends_on "libusb"

  uses_from_macos "vim" => :build # for xxd

  deny_network_access!

  def install
    bin.mkpath
    system "make", "install", "INSTALL_PREFIX=#{prefix}"
  end

  def caveats
    <<~EOS
      To boot a Compute Module with the default mass storage gadget:
        sudo rpiboot -d "$(brew --prefix rpiboot)"/share/rpiboot/mass-storage-gadget64
    EOS
  end

  test do
    assert_match "RPIBOOT: build-date", shell_output("#{bin}/rpiboot --version")
    assert_match "Usage: rpiboot", shell_output("#{bin}/rpiboot --help")
  end
end
