class TaLib < Formula
  desc "Tools for market analysis"
  homepage "https://ta-lib.org/"
  url "https://github.com/ta-lib/ta-lib/releases/download/v0.8.3/ta-lib-0.8.3-src.tar.gz"
  sha256 "28b1179b178a0db15f3dad0d846ef77f18eb06db5dfc5b5a8ca153a9ea5d84e6"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "2363482a68a78562473367bc5deab06d6f0d858ee17d1836f422b890b19a7eab"
  end

  on_macos do
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    ENV.deparallelize
    # Call autoreconf on macOS to fix -flat_namespace usage
    system "autoreconf", "--force", "--install", "--verbose" if OS.mac?
    system "./configure", *std_configure_args
    system "make", "install"
    bin.install "src/tools/ta_regtest/.libs/ta_regtest"
  end

  test do
    system bin/"ta_regtest"
  end
end
