class IosWebkitDebugProxy < Formula
  desc "DevTools proxy for iOS devices"
  homepage "https://github.com/google/ios-webkit-debug-proxy"
  url "https://github.com/google/ios-webkit-debug-proxy/archive/refs/tags/v1.9.3.tar.gz"
  sha256 "799477f40f5429a8355641a80f4ba6f415cfc8b3af6a86ba4fd448cdf9be30a1"
  license "BSD-3-Clause"
  head "https://github.com/google/ios-webkit-debug-proxy.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "324d600670a9eb23b7998f31ec56b4b925eb8b38ac0ff2834c075a40a5f60e9e"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "libimobiledevice"
  depends_on "libplist"
  depends_on "libusbmuxd"
  depends_on "openssl@4"

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
