class Bcftools < Formula
  desc "Tools for BCF/VCF files and variant calling from samtools"
  homepage "https://www.htslib.org/"
  url "https://github.com/samtools/bcftools/releases/download/1.25/bcftools-1.25.tar.bz2"
  sha256 "f96e583d2315998645bb56756f1c8f230c489512db2655b0f623198ebc8a2d99"
  # The bcftools source code is MIT/Expat-licensed, but when it is configured
  # with --enable-libgsl the resulting executable is GPL-licensed.
  license "GPL-3.0-or-later"
  compatibility_version 1

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "1e8656b1d191fb7f3d6a0bb379439791cc6209929c932bab86ae342db84db4b9"
  end

  depends_on "gsl"
  depends_on "htslib"

  deny_network_access!

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--with-htslib=#{formula_opt_prefix("htslib")}",
                          "--enable-libgsl"
    system "make", "install"
    pkgshare.install "test/query.vcf"
  end

  test do
    output = shell_output("#{bin}/bcftools stats #{pkgshare}/query.vcf")
    assert_match "number of SNPs:\t3", output
    assert_match "fixploidy", shell_output("#{bin}/bcftools plugin -l")
  end
end
