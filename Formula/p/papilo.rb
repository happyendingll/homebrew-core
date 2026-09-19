class Papilo < Formula
  desc "Parallel Presolve for Integer and Linear Optimization"
  homepage "https://www.scipopt.org", browsed: "2026-09-18"
  url "https://github.com/scipopt/papilo/archive/refs/tags/v3.0.2.tar.gz"
  sha256 "3ab6e4a41667aa1edc87697dfcc0dc7d517d047d4366abafd8858d22e02d4f2f"
  license "Apache-2.0"
  version_scheme 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "cbae22dc7551f0f161c98d7984afeae657df67febe97940a83e45e24d3261749"
  end

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "gcc" # for gfortran
  depends_on "gmp"
  depends_on "openblas"
  depends_on "tbb"

  deny_network_access!

  def install
    cmake_args = %w[
      -DBOOST=ON
      -DGMP=ON
      -DLUSOL=ON
      -DQUADMATH=ON
      -DTBB=ON
      -DBLA_VENDOR=OpenBLAS
    ]

    system "cmake", "-B", "papilo-build", "-S", ".", *cmake_args, *std_cmake_args
    system "cmake", "--build", "papilo-build"
    system "cmake", "--install", "papilo-build"

    pkgshare.install "test/instances/test.mps"
  end

  test do
    output = shell_output("#{bin}/papilo presolve -f #{pkgshare}/test.mps")
    assert_match "presolving finished after", output
  end
end
