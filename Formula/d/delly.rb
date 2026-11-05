class Delly < Formula
  desc "Structural variant discovery by paired-end and split-read analysis"
  homepage "https://github.com/dellytools/delly"
  url "https://github.com/dellytools/delly/archive/refs/tags/v2.8.1.tar.gz"
  sha256 "09cfe5e6678ddd9da8b21667c0a593ad3c4dcac55bccfb04d068cebfc252f425"
  license "BSD-3-Clause"
  head "https://github.com/dellytools/delly.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "3f32269d36364cda0a89968fc84f550b96eeb4c2f023beaf03dbebeab95a565d"
  end

  depends_on "boost"
  depends_on "htslib"
  depends_on "xz"

  uses_from_macos "bzip2"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "make", "src/delly",
           "HTSLIBINCDIR=#{formula_opt_include("htslib")}",
           "HTSLIBLIBDIR=#{formula_opt_lib("htslib")}",
           "BOOSTINCDIR=#{formula_opt_include("boost")}",
           "BOOSTLIBDIR=#{formula_opt_lib("boost")}"
    bin.install "src/delly"
    pkgshare.install %w[example R scripts]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/delly --version 2>&1")
    system bin/"delly", "lr", "-g", pkgshare/"example/ref.fa", "-o", testpath/"lr.bcf", pkgshare/"example/lr.bam"
    assert_path_exists testpath/"lr.bcf"
  end
end
