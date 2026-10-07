class Rpiboot < Formula
  desc "Raspberry Pi USB boot tool for Compute Modules"
  homepage "https://github.com/raspberrypi/usbboot"
  url "https://github.com/raspberrypi/usbboot.git",
      tag:      "20261002-115811",
      revision: "51006f8d77dbb99c408737825dd0d57285b7d00d"
  version "20261002-115811"
  license "Apache-2.0"
  head "https://github.com/raspberrypi/usbboot.git", branch: "master"

  livecheck do
    url :stable
    regex(/^(\d{8}-\d{6})$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "8cb188a56c1144dea51c54abbfa08ba2041c9d8abcb89416021c5d79481b3b15"
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
