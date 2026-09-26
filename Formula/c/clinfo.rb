class Clinfo < Formula
  desc "Print information about OpenCL platforms and devices"
  homepage "https://github.com/Oblomov/clinfo"
  url "https://github.com/Oblomov/clinfo/archive/refs/tags/3.1.26.09.26.tar.gz"
  sha256 "e944132329c6613b686ba0fcd373b15ebb553c367a01a734af8519ddb095c01f"
  license "CC0-1.0"
  head "https://github.com/Oblomov/clinfo.git", branch: "master"

  livecheck do
    url :homepage
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "8af13a706035a1dbd81017bae70ead39104a1e4e45ed3699190574bfaadcafa7"
  end

  on_linux do
    depends_on "opencl-headers" => :build
    depends_on "opencl-icd-loader"
    depends_on "pocl"
  end

  def install
    system "make", "MANDIR=#{man}", "PREFIX=#{prefix}", "install"
  end

  test do
    # OpenCL does not work on virtualized arm64 macOS.
    if Hardware::CPU.virtualized? && Hardware::CPU.arm? && OS.mac?
      assert_match "number of devices : error -30", shell_output("#{bin}/clinfo 2>&1", 1)
    else
      assert_match(/Device Type +[CG]PU/, shell_output(bin/"clinfo"))
    end
  end
end
