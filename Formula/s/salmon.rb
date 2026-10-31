class Salmon < Formula
  desc "Transcript-level quantification from RNA-seq reads"
  homepage "https://github.com/COMBINE-lab/salmon"
  url "https://github.com/COMBINE-lab/salmon/archive/refs/tags/v2.9.0.tar.gz"
  sha256 "72ec70a867e47a1b08925eee11c4f4288105a4350ae66b22906c346b71de96f7"
  license "BSD-3-Clause"
  head "https://github.com/COMBINE-lab/salmon.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "b6395eb26e2b1d0aa86c1e3a4d7180fceb3d67f99d69c2154fbfae65aadc72aa"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4ba5db1508e6a73c37fddb0bc70ed3b3d9b6bd09f55909935ec12f57cad4247d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "82b3295f28ebd15ead4a222cf3f27edf32f155eda6d1af4b8d9ec496965e4e9f"
    sha256 cellar: :any,                 arm64_linux:       "4e2ec2a363528e1b51e13e751c24953a16c3a94a041f332f34ad40c391e28352"
    sha256 cellar: :any,                 x86_64_linux:      "84108f0929238ba18d92346958af3f95e0baa1252fe688ba2510b434edd7dd4b"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/salmon-cli")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/salmon --version")

    (testpath/"txome.fa").write ">t0\n#{"ACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGT" * 4}\n"
    system bin/"salmon", "index", "-t", "txome.fa", "-i", "idx", "-k", "31"
    assert_predicate testpath/"idx", :directory?
  end
end
