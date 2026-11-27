class Pjproject < Formula
  desc "C library for multimedia protocols such as SIP, SDP, RTP and more"
  homepage "https://www.pjsip.org/"
  url "https://github.com/pjsip/pjproject/archive/refs/tags/2.18.tar.gz"
  sha256 "3b5e875d6023e608b3230901cc50b08582d8483a647d0c11578ac29f39101634"
  license "GPL-2.0-or-later"
  head "https://github.com/pjsip/pjproject.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "0229c9ce7504bebeb2ccfdecbaff5ac6653486c8140e4ba1ed4232b633ca111c"
  end

  depends_on "openssl@4"

  deny_network_access!

  def install
    system "./configure", *std_configure_args
    ENV.deparallelize
    system "make", "dep"
    system "make"
    system "make", "install"

    arch = Hardware::CPU.arm? ? "aarch64" : Hardware::CPU.arch.to_s
    target = if OS.mac?
      "apple-darwin#{OS.kernel_version}"
    elsif Hardware::CPU.arm?
      "unknown-linux-gnu"
    else
      "pc-linux-gnu"
    end

    bin.install "pjsip-apps/bin/pjsua-#{arch}-#{target}" => "pjsua"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pjsua --version 2>&1")
  end
end
