class Cloudprober < Formula
  desc "Active monitoring software to detect failures before your customers do"
  homepage "https://cloudprober.org"
  url "https://github.com/cloudprober/cloudprober/archive/refs/tags/v0.14.6.tar.gz"
  sha256 "5ee0bba29d64ee49eefcefc9e4dee6df279c34215729178265fbee2b200311ea"
  license "Apache-2.0"
  head "https://github.com/cloudprober/cloudprober.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "e78752987cb11179d97f7b3c4ded166a2bdddf5b144d41d6a92329c9a9f95173"
  end

  depends_on "go" => :build

  def install
    system "make", "cloudprober", "VERSION=v#{version}"
    bin.install "cloudprober"
  end

  test do
    io = IO.popen("#{bin}/cloudprober --logtostderr", err: [:child, :out])
    io.any? do |line|
      line.include?("Initialized status surfacer")
    end
  end
end
