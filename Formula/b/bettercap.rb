class Bettercap < Formula
  desc "Swiss army knife for network attacks and monitoring"
  homepage "https://www.bettercap.org/"
  url "https://github.com/bettercap/bettercap/archive/refs/tags/v2.42.0.tar.gz"
  sha256 "cdcce5b68b426c286b0b6aa1aabd2c84f6e891dd3b6e441d4a61de07ccf653a3"
  license "GPL-3.0-only"
  head "https://github.com/bettercap/bettercap.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "d2ce72cdc3bbad9945241aa0d5dd8d18ff1dfbd0e9571d05f12f4f976a5ea284"
  end

  depends_on "go" => :build
  depends_on "pkgconf" => :build
  depends_on "libusb"

  uses_from_macos "libpcap"

  on_linux do
    depends_on "libnetfilter-queue"
  end

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?
    system "make", "build"
    bin.install "bettercap"
  end

  def caveats
    <<~EOS
      bettercap requires root privileges so you will need to run `sudo bettercap`.
      You should be certain that you trust any software you grant root privileges.
    EOS
  end

  test do
    expected = if OS.mac?
      "Operation not permitted"
    else
      "Permission Denied"
    end
    assert_match expected, shell_output("#{bin}/bettercap 2>&1", 1)
  end
end
