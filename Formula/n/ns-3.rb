class Ns3 < Formula
  desc "Discrete-event network simulator"
  homepage "https://www.nsnam.org/"
  url "https://gitlab.com/nsnam/ns-3-dev/-/archive/ns-3.49/ns-3-dev-ns-3.49.tar.gz"
  sha256 "da24e895f41f7480e3b80fce0f9eca76923de1ea8848b5fb72cdae5b24b94b79"
  license "GPL-2.0-only"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "68f253343e9d54627f506b25b4abb395396e7256a4b1805f4d978abeb6820427"
  end

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "open-mpi"

  uses_from_macos "python" => :build
  uses_from_macos "libxml2"
  uses_from_macos "sqlite"

  def install
    # Fix binding's rpath
    linker_flags = ["-Wl,-rpath,#{loader_path}"]

    # NOTE: Do not enable GSL support as it is GPL-3.0-or-later which is
    # incompatible with GPL-2.0-only resulting in non-distributable binaries.
    # See https://www.gnu.org/licenses/gpl-faq.html#AllCompatibility
    args = %W[
      -DNS3_GSL=OFF
      -DNS3_GTK3=OFF
      -DNS3_PYTHON_BINDINGS=OFF
      -DNS3_MPI=ON
      -DCMAKE_SHARED_LINKER_FLAGS=#{linker_flags.join(" ")}
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "examples/tutorial/first.cc"
  end

  test do
    system ENV.cxx, "-std=c++20", "-o", "test", pkgshare/"first.cc", "-I#{include}", "-L#{lib}",
           "-lns#{version}-core", "-lns#{version}-network", "-lns#{version}-internet",
           "-lns#{version}-point-to-point", "-lns#{version}-applications"
    system "./test"
  end
end
