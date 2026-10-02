class Precice < Formula
  desc "Coupling library for partitioned multi-physics simulations"
  homepage "https://precice.org/"
  url "https://github.com/precice/precice/archive/refs/tags/v3.4.1.tar.gz"
  sha256 "ef4713c938a1b2000d0b071175e1b45f9ec55c7aec4bbe7b65c3992edcc74ac7"
  license "LGPL-3.0-or-later"
  revision 5
  head "https://github.com/precice/precice.git", branch: "develop"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "823cc87a07d652865d5707b4c016f771da9a530546b3b8916e9989a6ef5df0f1"
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "eigen" => :no_linkage
  depends_on "ginkgo"
  depends_on "kokkos"
  depends_on "numpy"
  depends_on "open-mpi"
  depends_on "petsc"
  depends_on "python@3.14"

  uses_from_macos "libxml2"

  on_macos do
    depends_on "libomp"
  end

  def install
    args = %W[
      -DPRECICE_FEATURE_GINKGO_MAPPING=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system bin/"precice-version", "version"
    system bin/"precice-config-doc", "md"
    system bin/"precice-config-validate", pkgshare/"examples/solverdummies/precice-config.xml"
  end
end
