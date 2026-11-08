class Libnetworkit < Formula
  desc "NetworKit is an OS-toolkit for large-scale network analysis"
  homepage "https://networkit.github.io"
  url "https://github.com/networkit/networkit/archive/refs/tags/11.3.tar.gz"
  sha256 "5aa5813110438270e9bb83c73f597943c4c5bedd5a9634fdaf5f2052a0053ba4"
  license "MIT"
  compatibility_version 1

  livecheck do
    formula "networkit"
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "fbad0f701296f40c9d404866da7ac0d9352a1de3efa0fc95e5141486c87972bb"
  end

  depends_on "cmake" => :build
  depends_on "tlx"
  depends_on "ttmath"

  on_macos do
    depends_on "libomp"
  end

  # Must match the `extlibs/dhb` submodule pinned by this release
  resource "dhb" do
    url "https://github.com/hu-macsy/dhb/archive/fb413abb5936ccf30d47e30a448cb8799c63b127.tar.gz"
    version "fb413abb5936ccf30d47e30a448cb8799c63b127"
    sha256 "3a0b726ce537359568cdf5e9ac73ff9606d7e6def1bf208a51d8f6971b3c0c2b"

    livecheck do
      url "https://api.github.com/repos/networkit/networkit/contents/extlibs/dhb?ref=#{LATEST_VERSION}"
      strategy :json do |json|
        json["sha"]
      end
    end
  end

  deny_network_access!

  def install
    resource("dhb").stage buildpath/"extlibs/dhb"
    system "cmake", "-S", ".", "-B", "build",
                    "-DNETWORKIT_EXT_TLX=#{formula_opt_prefix("tlx")}",
                    "-DNETWORKIT_CXX_STANDARD=20",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <networkit/graph/Graph.hpp>
      int main()
      {
        // Try to create a graph with five nodes
        NetworKit::Graph g(5);
        return 0;
      }
    CPP
    omp_flags = OS.mac? ? ["-I#{formula_opt_include("libomp")}"] : []
    system ENV.cxx, "-std=c++20", "test.cpp", "-L#{lib}", "-lnetworkit", "-o", "test", *omp_flags
    system "./test"
  end
end
