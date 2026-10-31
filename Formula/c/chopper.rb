class Chopper < Formula
  desc "Filter and trim long-read sequencing data by quality and length"
  homepage "https://github.com/wdecoster/chopper"
  url "https://github.com/wdecoster/chopper/archive/refs/tags/v0.15.0.tar.gz"
  sha256 "9193c545fca75eb580b0d04f2434fa2f36fbb6a95969c38956546ba0aaac0576"
  license "MIT"
  head "https://github.com/wdecoster/chopper.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "4eb0282be9e2322f235e457477864b0d0079c55829a6dfa8be036ded79eda0e1"
  end

  depends_on "cmake" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
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
