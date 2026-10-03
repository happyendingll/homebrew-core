class IosWebkitDebugProxy < Formula
  desc "DevTools proxy for iOS devices"
  homepage "https://github.com/google/ios-webkit-debug-proxy"
  url "https://github.com/google/ios-webkit-debug-proxy/archive/refs/tags/v1.9.2.tar.gz"
  sha256 "768f101612bf5d2507957f10a8e34e98675ea8fe3c63b8ed78772f8abd103fbf"
  license "BSD-3-Clause"
  revision 1
  head "https://github.com/google/ios-webkit-debug-proxy.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "716ebd2840ed0c907f028af80284e71c34ab10c97afcd23087fbc11dbbdca18c"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "libimobiledevice"
  depends_on "libplist"
  depends_on "libusbmuxd"
  depends_on "openssl@3"

  allow_network_access! :test

  def install
    system "./autogen.sh", *std_configure_args
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ios_webkit_debug_proxy --version")

    base_port = free_port
    (testpath/"config.csv").write <<~CSV
      null:#{base_port},:#{base_port + 1}-#{base_port + 101}
    CSV

    output_log = testpath/"output.log"
    pid = spawn "#{bin}/ios_webkit_debug_proxy", "-c", testpath/"config.csv", [:out, :err] => output_log.to_s
    sleep 2
    # Setup fails in both macOS sandbox and Linux where we don't have usbmuxd daemon
    assert_match "No device found, is it plugged in?", output_log.read
  ensure
    if pid
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
