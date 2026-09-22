class Iqtree3 < Formula
  desc "Phylogenetics by maximum likelihood"
  homepage "http://www.iqtree.org"
  url "https://github.com/iqtree/iqtree3/archive/refs/tags/v3.1.4.tar.gz"
  sha256 "8bcba50d25263fb7e5d52d308f7d2a35545dd53f96e04cf44e6a0515be0f823b"
  license "GPL-2.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "1dea092fe679e464fcf55c0c49ae53d6689053aa488b411d9b00c4ad8989db3a"
  end

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "eigen" => :build

  on_linux do
    depends_on "zlib-ng-compat"
  end

  resource "lsd2" do
    url "https://github.com/tothuhien/lsd2/archive/c61110f3a4fa05325b45c97b2134792ff9d55d4c.tar.gz"
    version "c61110f3a4fa05325b45c97b2134792ff9d55d4c"
    sha256 "9bbeaa0f8f35783c1d8dec74df6c93a804dbca808fa04484f9123de4e7258b53"

    livecheck do
      url "https://api.github.com/repos/iqtree/iqtree3/contents/lsd2?ref=v#{LATEST_VERSION}"
      strategy :json do |json|
        json["sha"]
      end
    end
  end

  deny_network_access!

  def install
    resource("lsd2").stage buildpath/"lsd2"

    args = %W[
      -DEIGEN3_INCLUDE_DIR=#{formula_opt_include("eigen")}/eigen3
      -DIQTREE_FLAGS=single
      -DUSE_CMAPLE=OFF
      -DUSE_TERRAPHAST=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    pkgshare.install "example"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/iqtree3 --version")

    cp_r pkgshare/"example/example.phy", testpath
    system bin/"iqtree3", "-s", "example.phy"
    assert_path_exists "example.phy.iqtree"
  end
end
