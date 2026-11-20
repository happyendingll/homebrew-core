class Mmseqs2 < Formula
  desc "Software suite for very fast sequence search and clustering"
  homepage "https://mmseqs.com/"
  url "https://github.com/soedinglab/MMseqs2/archive/refs/tags/19-ab57c.tar.gz"
  version "19-ab57c"
  sha256 "68b20700b82c93f2a30a8a7fbe545ab6ec715bfccb13ddcab144d3f3f504c5a4"
  license "MIT"
  head "https://github.com/soedinglab/MMseqs2.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "0a6fb14755dd545abb1921d78d16de3094534e7f92d873dc2737eb8a815ad096"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "rust" => :build
  depends_on "wget"

  uses_from_macos "bzip2"

  on_macos do
    depends_on "libomp"
  end

  on_linux do
    depends_on "gawk"
    depends_on "zlib-ng-compat"
  end

  resource "homebrew-testdata", :test do
    url "https://github.com/soedinglab/MMseqs2/releases/download/12-113e3/MMseqs2-Regression-Minimal.zip"
    sha256 "ab0c2953d1c27736c22a57a1ccbb976c1320435fad82b5c579dbd716b7bae4ce"
  end

  allow_network_access! :test

  def install
    args = %W[
      -DHAVE_TESTS=0
      -DHAVE_MPI=0
      -DVERSION_OVERRIDE=#{version}
    ]

    args << if Hardware::CPU.arm?
      "-DHAVE_ARM8=1"
    else
      "-DHAVE_SSE2=1" # need to support Core 2
    end

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "examples"
    bash_completion.install "util/bash-completion.sh" => "mmseqs.sh"
  end

  test do
    resource("homebrew-testdata").stage do
      ENV["CMAKE_POLICY_VERSION_MINIMUM"] = "3.5"
      system "./run_regression.sh", "#{bin}/mmseqs", "scratch"
    end
  end
end
