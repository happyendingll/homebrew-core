class Vcflib < Formula
  desc "C++ library and cmdline tools for parsing and manipulating VCF files"
  homepage "https://github.com/vcflib/vcflib"
  url "https://github.com/vcflib/vcflib/releases/download/v1.0.15/vcflib-1.0.15-src.tar.gz"
  sha256 "178e8c27fffc5324ac73f1c4b35f407184271b57f82aedc2efb9703df6ee3d49"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "1b2f60927f64ae261f78a16dbc1426592f69531302ba64978743500b0140135e"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "pybind11" => :build
  depends_on "python@3.15" => [:build, :test]
  depends_on "htslib"
  depends_on "wfa2-lib"
  depends_on "xz"

  uses_from_macos "bzip2"

  on_macos do
    depends_on "libomp"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    args = ["-DZIG=OFF"]
    args << "-DCMAKE_INSTALL_RPATH=#{rpath}" if OS.mac?
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vcfcheck --version")

    assert_match "fileformat=VCF", shell_output("#{bin}/vcfrandom")

    ENV["PYTHONPATH"] = lib
    system python3, "-c", "import pyvcflib"
  end
end
