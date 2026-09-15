class Nanopb < Formula
  include Language::Python::Shebang
  include Language::Python::Virtualenv

  desc "C library for encoding and decoding Protocol Buffer messages"
  homepage "https://jpa.kapsi.fi/nanopb/docs/index.html"
  url "https://jpa.kapsi.fi/nanopb/download/nanopb-0.4.9.2.tar.gz"
  sha256 "98b8cadce538f37230ca0d5d8796894e3067d58dd2fb2618e6712c7362bdd8bb"
  license "Zlib"
  head "https://github.com/nanopb/nanopb.git", branch: "master"

  livecheck do
    url "https://jpa.kapsi.fi/nanopb/download/"
    regex(/href=.*?nanopb[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "02b599ade069c8414715064e8e02660b2e1400f2c7ea6b31c994ec58a5bedfe3"
  end

  depends_on "cmake" => :build
  depends_on "protobuf" => :no_linkage
  depends_on "python@3.14"

  # Restore `package_name: "nanopb"` when 0.4.9.2 is on PyPI
  pypi_packages package_name: "", extra_packages: "protobuf"

  resource "protobuf" do
    url "https://files.pythonhosted.org/packages/86/73/f66c748df06e7fe24e658eddd600d19c4b40bad836c97ce2d0ad9851fb6b/protobuf-7.36.1.tar.gz"
    sha256 "d0f6470f0ce2b84e3feaea2d4b816378b37ba4d4aa08a274305373de93e2d524"
  end

  def install
    ENV.append_to_cflags "-DPB_ENABLE_MALLOC=1"
    venv = virtualenv_create(libexec, python3)
    venv.pip_install resources

    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_SHARED_LIBS=ON",
                    "-Dnanopb_PYTHON_INSTDIR_OVERRIDE=#{venv.site_packages}",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    rewrite_shebang python_shebang_rewrite_info(venv.root/"bin/python"), *bin.children
  end

  test do
    (testpath/"test.proto").write <<~PROTO
      syntax = "proto2";

      message Test {
        required string test_field = 1;
      }
    PROTO

    system formula_opt_bin("protobuf")/"protoc", "--nanopb_out=.", "test.proto"
    assert_match "Test", (testpath/"test.pb.c").read
    assert_match "Test", (testpath/"test.pb.h").read
  end
end
