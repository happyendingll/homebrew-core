class Mmseqs2 < Formula
  desc "Software suite for very fast sequence search and clustering"
  homepage "https://mmseqs.com/"
  url "https://github.com/soedinglab/MMseqs2/archive/refs/tags/20-ae60e.tar.gz"
  version "20-ae60e"
  sha256 "0245e45b705bbcd14e46291d82c977aff0a3600200f36c4d04dceb57d211dabc"
  license "MIT"
  head "https://github.com/soedinglab/MMseqs2.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "23bd3148141721c4a6b3fceee5dd6fa7d7050761a37f1c27b83db5ca5710a82a"
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
