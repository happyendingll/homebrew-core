class Getxbook < Formula
  desc "Tools to download ebooks from various sources"
  homepage "https://njw.name/getxbook/"
  url "https://njw.name/getxbook/getxbook-1.3.tar.xz"
  sha256 "a1b8252a50ba61e7c66a82161af35e08f4e6187e8c2cea1e2a040d167932de18"
  license "ISC"

  livecheck do
    url :homepage
    regex(/href=.*?getxbook[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "3bfc263a200b7a6c5fd279fccea6b10763162383107df221d611aec79a49d37a"
  end

  depends_on "openssl@3"

  def install
    system "make", "CC=#{ENV.cc}", "PREFIX=#{prefix}"
    bin.install "getgbook", "getabook", "getbnbook"
  end

  test do
    assert_match "getgbook #{version}", shell_output("#{bin}/getgbook", 1)
  end
end
