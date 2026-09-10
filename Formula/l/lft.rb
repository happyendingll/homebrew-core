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
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b762c7dcb2b21e46e797fc10104e507d966b4622aa89f966e82ba4b6369d905c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "577eff6c7459b3237079ab50a2c3962bb20339c235f1a08bd1fca27d2b164d50"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e1ab65dae3e76d8f181da7197e121f3e8352ba7fa7729fccbb6a8a4760f1b784"
    sha256 cellar: :any,                 arm64_linux:   "6f3b8a00a5c6f1e74dfad1fdecde55623374243c89a8848725b295daec95ff9b"
    sha256 cellar: :any,                 x86_64_linux:  "ca27368d53945a8ae132aa3133bc4c8314c3fd7635138bf97d9b5f7c7ab50fc0"
  end

  uses_from_macos "libpcap"

  def install
    args = %w[
      --disable-async-dns
      --disable-ncurses
    ]
    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/lft -S -d 443 brew.sh 2>&1", 1)
    assert_match(/LFT: (insufficient privileges|Failed to activate capture on device)/, output)
  end
end
