class Corkscrew < Formula
  desc "Tunnel SSH through HTTP proxies"
  homepage "https://packages.debian.org/sid/corkscrew"
  url "https://deb.debian.org/debian/pool/main/c/corkscrew/corkscrew_3.1.orig.tar.gz"
  sha256 "0f9c62466b4cbb13e3384eda2e00eb5e793acf82a5c2980d81a334151d202255"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://deb.debian.org/debian/pool/main/c/corkscrew/"
    regex(/href=.*?corkscrew[._-]v?(\d+(?:\.\d+)+)\.orig\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "be635e69947d153e6250cdd7ebbbe6990795a4d96710f0562699cae0c10d2ec8"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  allow_network_access! :test

  def install
    # Generated Autotools files are not shipped in the source tarball
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    port = free_port

    fork do
      server = TCPServer.new port
      socket = server.accept
      Open3.popen3("#{bin}/corkscrew 127.0.0.1 #{port} www.google.com 80") do |_, stdout, _|
        socket.write "GET /index.html HTTP/1.1\r\n\r\n"
        assert_match "HTTP/1.1", stdout.gets("\r\n\r\n")
      end
    end
  end
end
