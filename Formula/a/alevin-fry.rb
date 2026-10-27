class AlevinFry < Formula
  desc "Efficient and flexible tool for processing single-cell sequencing data"
  homepage "https://github.com/COMBINE-lab/alevin-fry"
  url "https://github.com/COMBINE-lab/alevin-fry/archive/refs/tags/v0.19.0.tar.gz"
  sha256 "033ab877f00b01ae226bf3c20756883c8f97d1e44e682cea1a30723769d79cbc"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "f22d567b1550dfd26669b1a2a4b849c0c3c0bbf3170daa3cbd6455a63bc85ce0"
  end

  depends_on "cmake" => :build
  depends_on "rust" => :build

  uses_from_macos "bzip2"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/alevin-fry --version")

    sam = testpath/"test.sam"
    sam.write <<~EOS
      @SQ\tSN:chr1\tLN:500
      r1\t0\tchr1\t100\t0\t4M\t*\t0\t0\tATGC\t*\tCR:Z:ATGC\tUR:Z:ATGC
    EOS
    system bin/"alevin-fry", "convert", "--bam", "test.sam", "--output", "test.rad"
    assert_path_exists "test.rad"
  end
end
