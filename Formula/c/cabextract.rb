class Cabextract < Formula
  desc "Extract files from Microsoft cabinet files"
  homepage "https://www.cabextract.org.uk/"
  url "https://www.cabextract.org.uk/cabextract-1.12.tar.gz"
  sha256 "8f39ad5f9c076b9c62c67dea4f8649e75dcc16899a2d8122ca32ba68262cb713"
  license "GPL-3.0-or-later"
  compatibility_version 1

  livecheck do
    url :homepage
    regex(/href=.*?cabextract[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "c7da4bdb6254f7073d1d367854652b9f059caa2b4fc9ae083ddb4e408a8c5902"
  end

  deny_network_access!

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    # probably the smallest valid .cab file
    cab = <<~EOS.gsub(/\s+/, "")
      4d5343460000000046000000000000002c000000000000000301010001000000d20400003
      e00000001000000000000000000000000003246899d200061000000000000000000
    EOS
    (testpath/"test.cab").binwrite [cab].pack("H*")

    system bin/"cabextract", "test.cab"
    assert_path_exists testpath/"a"
  end
end
