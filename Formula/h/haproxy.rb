class Haproxy < Formula
  desc "Reliable, high performance TCP/HTTP load balancer"
  homepage "https://www.haproxy.org/"
  url "https://www.haproxy.org/download/3.4/src/haproxy-3.4.5.tar.gz"
  sha256 "ec5095095bce7db2e0e6e971f616dded1bb505717e692ec6c3cc8dab6a31678a"
  license "GPL-2.0-or-later" => { with: "openvpn-openssl-exception" }

  livecheck do
    url :homepage
    regex(/href=.*?haproxy[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "df7ad24e3c1fd38f93602d2608f8b771be5952b6af51c509f070fae1b4d051a7"
    sha256 cellar: :any, arm64_tahoe:       "b8b2480caf707e5aebb29d00f8602491af6620a3be42f5a31924fdabeb90db7e"
    sha256 cellar: :any, arm64_sequoia:     "cb9e8fdf8328525d1830033b2ceaea54522bb07156e7405f28336e05d4eedf33"
    sha256 cellar: :any, arm64_linux:       "3b20af916c3b6e0f6019b415ff15901cfbfbae565492192cfd618eb71d358f2f"
    sha256 cellar: :any, x86_64_linux:      "ca8b7f647ba1e8594dbb9fbb31ff200aae2e23f7967669c6c07849cd95ff66a5"
  end

  depends_on "openssl@4"
  depends_on "pcre2"

  uses_from_macos "libxcrypt"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    args = %w[
      USE_PCRE2=1
      USE_PCRE2_JIT=1
      USE_OPENSSL=1
      USE_PROMEX=1
      USE_QUIC=1
      USE_ZLIB=1
    ]

    target = if OS.mac?
      "osx"
    else
      "linux-glibc"
    end
    args << "TARGET=#{target}"

    # We build generic since the Makefile.osx doesn't appear to work
    system "make", *args
    man1.install "doc/haproxy.1"
    bin.install "haproxy"
  end

  service do
    run [opt_bin/"haproxy", "-f", etc/"haproxy.cfg"]
    keep_alive true
    log_path var/"log/haproxy.log"
    error_log_path var/"log/haproxy.log"
  end

  test do
    system bin/"haproxy", "-v"
  end
end
