class Cuttlefish < Formula
  desc "Build compacted de Bruijn graphs from references or reads"
  homepage "https://combine-lab.github.io/cuttlefish/"
  url "https://github.com/COMBINE-lab/cuttlefish/archive/refs/tags/v3.0.3.tar.gz"
  sha256 "dbe3fff5aebf72bfee2fc0f3f81fc2ec4ce9e599f52f3e9f3485cc8931679a7d"
  license "BSD-3-Clause"
  head "https://github.com/COMBINE-lab/cuttlefish.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "5e8efb28e49bd04755ced8b2fc824aafb5e686dd678f227b244b5a405a188191"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/cuttlefish-rs-cli")
  end

  test do
    seq = "ACGTTGCAATCGGATCCTAGGCATTACGGTTACCGATTCAGGCTAAGTCCATGGCATCAGT"

    (testpath/"ref.fa").write <<~FASTA
      >test
      #{seq}
    FASTA

    system bin/"cuttlefish", "build", "--ref", "--seq", "ref.fa",
           "-k", "31", "-t", "1", "-w", testpath/"work", "-o", testpath/"graph"

    unitigs = (testpath/"graph.fa").read.lines.grep_v(/^>/).map(&:chomp)
    assert_equal 1, unitigs.length
    assert_equal seq.length, unitigs.first.length

    assert_match version.to_s, shell_output("#{bin}/cuttlefish version")
  end
end
