class RaxmlNg < Formula
  desc "RAxML Next Generation: faster, easier-to-use and more flexible"
  homepage "https://cme.h-its.org/exelixis/web/software/raxml/"
  url "https://github.com/amkozlov/raxml-ng.git",
      tag:      "2.0.3",
      revision: "173b012f9989bfdd53970e6917e4037be3d1e38e"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "abead424e1396e1031986fb4a02b0acac7343f33a04a7ff05ffec69e27fd31e0"
  end

  depends_on "bison" => :build # fix syntax error with `parse_utree.y`
  depends_on "cmake" => :build
  depends_on "gmp"

  uses_from_macos "flex" => :build

  on_linux do
    depends_on "open-mpi"
  end

  def install
    args = %w[-DUSE_GMP=ON]
    # Workaround to build with CMake 4
    args << "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    if Hardware::CPU.arm?
      # `PORTABLE_BUILD=ON` still enables x86 SIMD paths on macOS arm64,
      # upstream issue ref, https://github.com/amkozlov/raxml-ng/issues/226.
      args << "-DPORTABLE_BUILD=ON"
      args += %w[
        -DCORAX_ENABLE_SSE=OFF
        -DCORAX_ENABLE_AVX=OFF
        -DCORAX_ENABLE_AVX2=OFF
      ]
    end

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Upstream doesn't support building MPI variant on macOS.
    # The build ignores USE_MPI=ON and forces ENABLE_MPI=OFF.
    # This causes necessary flags like -D_RAXML_MPI to not get set.
    return if OS.mac?

    args << "-DUSE_MPI=ON"
    system "cmake", "-S", ".", "-B", "build_mpi", *args, *std_cmake_args
    system "cmake", "--build", "build_mpi"
    system "cmake", "--install", "build_mpi"
  end

  test do
    resource "homebrew-example" do
      url "https://cme.h-its.org/exelixis/resource/download/hands-on/dna.phy"
      sha256 "c2adc42823313831b97af76b3b1503b84573f10d9d0d563be5815cde0effe0c2"
    end

    testpath.install resource("homebrew-example")
    # `--start` fails with missing `startTree` output on 2.0.0,
    # upstream issue ref, https://github.com/amkozlov/raxml-ng/issues/227.
    system bin/"raxml-ng", "--parse", "--msa", "dna.phy", "--model", "GTR"
    assert_path_exists testpath/"dna.phy.raxml.rba"
  end
end
