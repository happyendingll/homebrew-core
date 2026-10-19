class Openfpgaloader < Formula
  desc "Universal utility for programming FPGA"
  homepage "https://trabucayre.github.io/openFPGALoader/"
  url "https://github.com/trabucayre/openFPGALoader/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "f75e9896bd8c6310f98ecd629ed260ecaa83329c31e0f8f831b07531aa64d30a"
  license "Apache-2.0"
  head "https://github.com/trabucayre/openFPGALoader.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "890a467fe689420986dafd7c4a01e197ad4029205fdcf4e73cccc3b3fbbf342a"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "libftdi"
  depends_on "libusb"

  on_linux do
    depends_on "systemd"
    depends_on "zlib-ng-compat"
  end

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    version_output = shell_output("#{bin}/openFPGALoader -V 2>&1")
    assert_match "openFPGALoader v#{version}", version_output

    error_output = shell_output("#{bin}/openFPGALoader --detect 2>&1 >/dev/null", 1)
    assert_includes error_output, "JTAG init failed"
  end
end
