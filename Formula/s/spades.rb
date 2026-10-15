class Spades < Formula
  include Language::Python::Shebang

  desc "De novo genome sequence assembly"
  homepage "https://ablab.github.io/spades/"
  url "https://github.com/ablab/spades/releases/download/v4.3.0/SPAdes-4.3.0.tar.gz"
  sha256 "09671ca39f9c6d2479d9fc168100bfd089b4a24002d51b815386d2b24d424456"
  license "GPL-2.0-only"
  head "https://github.com/ablab/spades.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "afdc9da49c8ca486faf5c914653038a0384531ef745615b6598fd0a647349ff4"
  end

  depends_on "cmake" => :build
  depends_on "python@3.15"

  uses_from_macos "bzip2" => :build

  on_macos do
    depends_on "libomp"
  end

  def install
    system "cmake", "-S", "src", "-B", "build", *std_cmake_args
    # Build bundled zlib-ng with runtime detection
    with_env(HOMEBREW_CCCFG: ENV["HOMEBREW_CCCFG"]) do
      ENV.runtime_cpu_detection
      system "cmake", "--build", "build", "--target", "zlibstatic"
    end
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    rewrite_shebang detected_python_shebang, *bin.children
  end

  test do
    assert_match "TEST PASSED CORRECTLY", shell_output("#{bin}/spades.py --test")
  end
end
