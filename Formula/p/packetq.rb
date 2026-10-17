class Packetq < Formula
  desc "SQL-like frontend to PCAP files"
  homepage "https://www.dns-oarc.net/tools/packetq"
  url "https://www.dns-oarc.net/files/packetq/packetq-1.8.0.tar.gz"
  sha256 "d89be327a505a86af0a76c3e41529998b75ebee10bd86e0c0b7f907666f9c741"
  license "GPL-3.0-or-later"

  livecheck do
    url :homepage
    regex(/href=.*?packetq[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "2e3ed876db392a3a2b1eb13949605303fd935fa40fa17dbc7216a31d0982b5f4"
  end

  depends_on "pkgconf" => :build
  depends_on "dnswire"
  depends_on "libmaxminddb"
  depends_on "protobuf-c"
  depends_on "tinyframe"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/packetq --csv -s 'select id from dns' -")
    assert_equal '"id"', output.chomp
  end
end
