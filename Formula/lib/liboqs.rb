class Liboqs < Formula
  desc "Library for quantum-safe cryptography"
  homepage "https://openquantumsafe.org/"
  url "https://github.com/open-quantum-safe/liboqs/archive/refs/tags/0.16.0.tar.gz"
  sha256 "162d5b510518ee5f285f82fa1f16402a885176e818bf1b1a4c3c91c9a2f01eae"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "b71c83c4a735a15670d0f6e67a5944b3d7046f8209d85543432380b99b5d5b89"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "ninja" => :build
  depends_on "openssl@4"

  deny_network_access!

  def openssl = "openssl@4"

  def install
    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DOQS_USE_OPENSSL=ON
      -DOPENSSL_ROOT_DIR=#{formula_opt_prefix(openssl)}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "tests"
  end

  test do
    cp pkgshare/"tests/example_kem.c", "test.c"
    system ENV.cc, "test.c",
                  "-I#{formula_opt_include(openssl)}", "-I#{include}",
                  "-L#{formula_opt_lib(openssl)}", "-L#{lib}",
                  "-loqs", "-lssl", "-lcrypto", "-o", "test"
    assert_match "operations completed", shell_output("./test")
  end
end
