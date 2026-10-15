class Partio < Formula
  desc "Particle library for 3D graphics"
  homepage "https://www.disneyanimation.com/open-source/partio/"
  url "https://github.com/wdas/partio/archive/refs/tags/v1.20.0.tar.gz"
  sha256 "e60a89364f2b5d9c9b1f143175fc1a5018027a59bb31af56e5df88806b506e49"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "84e7db7a32138f18e3e44d64a4f6c0f2a19e09210952311a4cf70bc9aa7d2f11"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "python@3.15"

  on_linux do
    depends_on "freeglut"
    depends_on "mesa"
    depends_on "mesa-glu"
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    args = std_cmake_args
    args << "-DPARTIO_USE_GLVND=OFF" unless OS.mac?

    system "cmake", "-S", ".", "-B", ".", *args
    system "cmake", "--build", "."
    system "cmake", "--build", ".", "--target", "doc"
    system "cmake", "--install", "."

    pkgshare.install "src/data"
  end

  test do
    assert_match "Number of particles:  25", shell_output("#{bin}/partinfo #{pkgshare}/data/scatter.bgeo")
  end
end
