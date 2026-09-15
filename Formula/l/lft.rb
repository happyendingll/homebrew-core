class Lft < Formula
  desc "Layer Four Traceroute (LFT), an advanced traceroute tool"
  homepage "https://pwhois.org/lft/"
  url "https://pwhois.org/dl/index.who?file=lft-4.01.tar.gz"
  sha256 "77a2923dbd10b1e3d2b55d8f3c4144795a80f73772d4f41f5e27751d1f3f0c62"
  license "VOSTROM"

  livecheck do
    url :homepage
    regex(/value=.*?lft[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "98987860eb53120ede85fccd691910041d45b42a2c5df2b06cfe55c5b8705ba0"
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
