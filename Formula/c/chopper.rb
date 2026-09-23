class Chopper < Formula
  desc "Filter and trim long-read sequencing data by quality and length"
  homepage "https://github.com/wdecoster/chopper"
  url "https://github.com/wdecoster/chopper/archive/refs/tags/v0.14.1.tar.gz"
  sha256 "899c3bb3e20da9b5ac232b413033dcc26e09c71f3aa222498ba25f4241fed56f"
  license "MIT"
  head "https://github.com/wdecoster/chopper.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "2bf0eb8b40ccfb447a53f6e7a2cf9217cd70a7fac08fd200c9a21ba3ba0cc184"
  end

  depends_on "cmake" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    # read1 is 32 bp, read2 is 4 bp; filtering for reads >= 10 bp drops read2
    (testpath/"reads.fq").write <<~EOS
      @read1
      ACGTACGTACGTACGTACGTACGTACGTACGT
      +
      IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
      @read2
      ACGT
      +
      IIII
    EOS

    output = shell_output("#{bin}/chopper -l 10 -i reads.fq")
    assert_includes output, "read1"
    refute_includes output, "read2"
  end
end
