class PlinkNg < Formula
  desc "Whole-genome association analysis toolset (PLINK 2.0)"
  homepage "https://www.cog-genomics.org/plink/2.0/"
  url "https://github.com/chrchang/plink-ng/archive/refs/tags/v2.0.0-b.1.1.tar.gz"
  version "2.0.0-b.1.1"
  sha256 "71d9ee5cd1828ec622dacc5345ce620ef3526ec3c816936bf01214a6d01a85cd"
  license all_of: ["GPL-3.0-or-later", "LGPL-3.0-or-later"]
  head "https://github.com/chrchang/plink-ng.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+-[ab]\.\d+(?:\.\d+)*)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "ee5b9657dbd4ad0e3e687a03278ba42ff3fe83c041d4560f515e863502da4692"
    sha256 cellar: :any, arm64_tahoe:       "cd95e1753ef5382a41ae274c374dad93049b8432f0cf1be24c04acdede50d578"
    sha256 cellar: :any, arm64_sequoia:     "60433ebb53a1149d4886c4ed31737def7de20d87743ef6c27d0616199419f892"
    sha256 cellar: :any, arm64_linux:       "dbb70e8688ad5fd3ff8d553e12ecb634b19e4a8f0e241ea0756ddfb5a20efa65"
    sha256 cellar: :any, x86_64_linux:      "eb4a975b70377cb36239c4b2c895b637860ee1010e7a9f8ddf11efff6eac0132"
  end

  depends_on "zstd"

  on_linux do
    depends_on "openblas"
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    cd "2.0/build_dynamic" do
      # Link against zstd rather than the bundled copy.
      args = ["STATIC_ZSTD="]
      # OpenBLAS ships LAPACK and LAPACKE, so a single -lopenblas is enough.
      args << "BLASFLAGS=-L#{formula_opt_lib("openblas")} -lopenblas" if OS.linux?

      system "make", *args
      bin.install "plink2", "pgen_compress"
    end
  end

  test do
    # Simulate a small cohort, then check the generated genotype file is usable.
    system bin/"plink2", "--dummy", "50", "100", "--out", "dummy"
    assert_path_exists testpath/"dummy.pgen"

    system bin/"plink2", "--pfile", "dummy", "--freq", "--out", "freq"
    freqs = (testpath/"freq.afreq").read
    assert_match "ALT_FREQS", freqs
    assert_equal 101, freqs.lines.count

    system bin/"plink2", "--pfile", "dummy", "--make-bed", "--out", "binary"
    assert_path_exists testpath/"binary.bed"

    # --pca goes through the BLAS/LAPACK backend; it needs rare variants filtered.
    system bin/"plink2", "--pfile", "dummy", "--maf", "0.05", "--pca", "2", "--out", "pca"
    assert_equal 2, (testpath/"pca.eigenval").read.lines.count
  end
end
