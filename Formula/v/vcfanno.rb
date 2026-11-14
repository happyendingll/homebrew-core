class Vcfanno < Formula
  desc "Annotate a VCF with other VCFs/BEDs/tabixed files"
  homepage "https://genomebiology.biomedcentral.com/articles/10.1186/s13059-016-0973-5"
  url "https://github.com/brentp/vcfanno/archive/refs/tags/v0.3.10.tar.gz"
  sha256 "6a13fc9fe247f2726b6294e55e713281e62e4a5c279501e60763c52c4c921d45"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "a5f9224c91d634a146555bb3b27437dd4f17c390b844c70a7a24035747e29d2f"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args
    pkgshare.install "example"
  end

  test do
    cp_r pkgshare/"example", testpath
    output = shell_output("#{bin}/vcfanno -lua example/custom.lua example/conf.toml example/query.vcf.gz")
    assert_match version.to_s, output
    assert_match "fileformat=VCF", output
  end
end
