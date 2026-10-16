class Nest < Formula
  desc "Neural Simulation Tool (NEST) with Python3 bindings (PyNEST)"
  homepage "https://www.nest-simulator.org/"
  url "https://github.com/nest/nest-simulator/archive/refs/tags/v3.10.tar.gz"
  sha256 "fd4def89c109e19d50e4630ab56bb9ddd4f15bf0ef735070189f0a83e2416a55"
  license "GPL-2.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "bafd0a57147bbdbd03b3ef16a9902301147753a6042e00252618b21ee15fdd96"
  end

  depends_on "cmake" => :build
  depends_on "cython" => :build
  depends_on "gsl"
  depends_on "libtool"
  depends_on "numpy"
  depends_on "python@3.15"
  depends_on "readline"

  uses_from_macos "ncurses"

  on_macos do
    depends_on "libomp"
  end

  deny_network_access!

  def install
    # Help FindReadline find macOS system ncurses library
    args = if OS.mac? && (sdk_path = MacOS.sdk_path)
      ["-DNCURSES_LIBRARY=#{sdk_path}/usr/lib/libncurses.tbd"]
    else
      []
    end

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Replace internally accessible gcc with externally accessible version
    # in nest-config if required
    inreplace bin/"nest-config", Superenv.shims_path/ENV.cxx, ENV.cxx
  end

  def caveats
    <<~EOS
      The PyNEST bindings and its dependencies are installed with the python@#{Language::Python.major_minor_version python3} formula.
      If you want to use PyNEST, use the Python interpreter from this path:

          #{python3.dirname}

      You may want to add this to your PATH.
    EOS
  end

  test do
    system bin/"nest-config", "--version"

    # check whether NEST is importable form python
    system python3, "-c", "'import nest'"
  end
end
