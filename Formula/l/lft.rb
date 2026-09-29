class Lft < Formula
  desc "Layer Four Traceroute (LFT), an advanced traceroute tool"
  homepage "https://pwhois.org/lft/"
  url "https://pwhois.org/dl/index.who?file=lft-4.03.tar.gz"
  sha256 "d84aff0c2baf57a5c5b21fb3b228eed0ac0e12e5a676b3b3be13e34770b91d17"
  license "VOSTROM"

  livecheck do
    url :homepage
    regex(/value=.*?lft[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "d688de8568568b6b1624c7fbfdd2d755bdfed95a3a7992bfcd6890127594c214"
  end

  depends_on "pkgconf" => :build
  depends_on "c-ares"
  depends_on "ncurses"

  uses_from_macos "libpcap"

  def install
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/lft -S -d 443 brew.sh 2>&1", 1)
    assert_match(/LFT: (insufficient privileges|Failed to activate capture on device)/, output)
  end
end
