class Chkrootkit < Formula
  desc "Rootkit detector"
  homepage "https://www.chkrootkit.org/"
  url "ftp://ftp.chkrootkit.org/pub/seg/pac/chkrootkit-0.60.tar.gz"
  mirror "https://fossies.org/linux/misc/chkrootkit-0.60.tar.gz"
  sha256 "bf43d227f99d6d9dd28c629a4e5f85d6a5de3cf83010feba5a04f4e1c5c5de28"
  license "GPL-2.0-or-later"

  livecheck do
    url :homepage
    regex(/href=.*?download[^>]*>chkrootkit v?(\d+(?:\.\d+)+[a-z]?)/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "e7a4efa69960abd6e44150aae730a48493bebf80ca21c2b963f392fc16f8fcb2"
  end

  def install
    ENV.deparallelize

    # Fix compile with newer Clang
    ENV.append_to_cflags "-Wno-implicit-function-declaration" if DevelopmentTools.clang_build_version >= 1403

    # Remove prebuilt Linux binaries shipped in the release archive.
    system "make", "clean"
    system "make", "CC=#{ENV.cc}", "CFLAGS=#{ENV.cflags}",
                   "STATIC=", "sense", "all"

    bin.install Dir[buildpath/"*"].select { |f| File.executable? f }
    doc.install %w[README README.chklastlog README.chkwtmp]
  end

  test do
    (testpath/"sample").write "\0homebrew\0chkrootkit\0"
    assert_equal "homebrew\nchkrootkit\n", shell_output("#{bin}/strings-static -a sample")
  end
end
