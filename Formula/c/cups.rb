class Cups < Formula
  desc "Common UNIX Printing System"
  homepage "https://github.com/OpenPrinting/cups"
  # This is the author's fork of CUPS. Debian have switched to this fork:
  # https://lists.debian.org/debian-printing/2020/12/msg00006.html
  url "https://github.com/OpenPrinting/cups/releases/download/v2.4.20/cups-2.4.20-source.tar.gz"
  sha256 "ab4d9cd7f3e58060091d2b24972223d6401675f11c49b65abf4f6ef31dea22ff"
  license "Apache-2.0" => { with: "LLVM-exception" }
  head "https://github.com/OpenPrinting/cups.git", branch: "master"

  livecheck do
    url :stable
    regex(/^(?:release[._-])?v?(\d+(?:\.\d+)+(?:op\d*)?)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "5707cb717fd908a17cfcbb7748b7bad0e2107f3a42a0f0b02a58bf95d82bbcb5"
  end

  keg_only :provided_by_macos

  depends_on "pkgconf" => :build
  depends_on "openssl@3"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # Fix builds without DNS-SD support, upstream PR ref, https://github.com/OpenPrinting/cups/pull/1740
  patch do
    url "https://github.com/OpenPrinting/cups/commit/23a183b63a4c94ae7cd0f36c63ee7eb905be60fd.patch?full_index=1"
    sha256 "8168c6048065abea242af383171b08b4b16b58d7b9831819f75b05c0d52ae0c5"
    type :unofficial
    resolves "https://github.com/OpenPrinting/cups/pull/1740"
  end

  allow_network_access! :test

  def install
    system "./configure", "--with-components=core",
                          "--with-tls=openssl",
                          *std_configure_args
    system "make", "install"
  end

  test do
    port = free_port.to_s
    pid = spawn "#{bin}/ippeveprinter", "-p", port, "Homebrew Test Printer"

    begin
      sleep 2
      assert_match("Homebrew Test Printer", shell_output("curl localhost:#{port}"))
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
