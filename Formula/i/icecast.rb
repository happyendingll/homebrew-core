class Icecast < Formula
  desc "Streaming MP3 audio server"
  homepage "https://icecast.org/"
  url "https://ftp.osuosl.org/pub/xiph/releases/icecast/icecast-2.4.4.tar.gz"
  mirror "https://mirror.csclub.uwaterloo.ca/xiph/releases/icecast/icecast-2.4.4.tar.gz"
  sha256 "49b5979f9f614140b6a38046154203ee28218d8fc549888596a683ad604e4d44"
  license "GPL-2.0-only"
  revision 4

  # Upstream has used a 999 patch version to presumably indicate an unstable
  # version. We've seen this in other projects that use a 90+ patch to indicate
  # unstable versions, so we use a related pattern in the regex to avoid those
  # potential versions as well.
  livecheck do
    url "https://ftp.osuosl.org/pub/xiph/releases/icecast/?C=M&O=D"
    regex(%r{href=(?:["']?|.*?/)icecast[._-]v?(\d+\.\d+(?:\.(?:\d|[1-8]\d+)(?:\.\d+)*)?)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "0e73b9f9d8b1ec4d653963e6745eac48cfc62ee5de8f0afa5337095de124763f"
  end

  depends_on "pkgconf" => :build

  depends_on "libogg"
  depends_on "libvorbis"
  depends_on "openssl@4"

  uses_from_macos "curl"
  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  allow_network_access! :test

  def install
    args = %W[
      --disable-silent-rules
      --without-speex
      --without-theora
      --sysconfdir=#{etc}
      --localstatedir=#{var}
    ]
    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  post_install_steps do
    touch "{{var}}/log/icecast/access.log"
    touch "{{var}}/log/icecast/error.log"
  end

  test do
    port = free_port

    cp etc/"icecast.xml", testpath/"icecast.xml"
    inreplace testpath/"icecast.xml", "<port>8000</port>", "<port>#{port}</port>"

    pid = spawn "icecast", "-c", testpath/"icecast.xml", err: "/dev/null"
    sleep 3

    begin
      assert_match "icestats", shell_output("curl localhost:#{port}/status-json.xsl")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
