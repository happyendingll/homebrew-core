class Hyphy < Formula
  desc "Hypothesis testing using Phylogenies"
  homepage "https://www.hyphy.org"
  url "https://github.com/veg/hyphy/archive/refs/tags/2.5.103.tar.gz"
  sha256 "e3602aa3add7f4d88c18038828bc49080a749dd377f9d41c92933fbf07d846c2"
  license "MIT"
  head "https://github.com/veg/hyphy.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "4b4325ca16ddec2b0295843cc078d42f8f6e6e3e38e54c6ee9e2a5660b0aa933"
  end

  depends_on "cmake" => :build

  uses_from_macos "curl"

  on_macos do
    depends_on "libomp"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hyphy --version")

    cp pkgshare/"data/p51.nex", testpath
    system bin/"hyphy", "slac", "--alignment", "p51.nex"
    assert_path_exists "p51.nex.SLAC.json"
  end
end
