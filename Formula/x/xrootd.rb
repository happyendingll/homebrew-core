class Xrootd < Formula
  desc "High performance, scalable, fault-tolerant access to data"
  homepage "https://xrootd.org/"
  url "https://github.com/xrootd/xrootd/releases/download/v6.2.1/xrootd-6.2.1.tar.gz"
  sha256 "43b974c4d2afb6a37687c2d81f0e61c1213fa46470c1da4b2b58e5d6319a6f26"
  license "LGPL-3.0-or-later"
  compatibility_version 1
  head "https://github.com/xrootd/xrootd.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "b8d15ac87bbf4bcb00ead08f2d18f693cf55818712f67796eb155505e59bdec8"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "python-setuptools" => :build
  depends_on "python@3.15" => [:build, :test]
  depends_on "davix"
  depends_on "krb5"
  depends_on "libzip"
  depends_on "openssl@4"
  depends_on "readline"

  uses_from_macos "curl"
  uses_from_macos "libxcrypt"
  uses_from_macos "libxml2"

  on_linux do
    depends_on "util-linux" # for libuuid
    depends_on "zlib-ng-compat"
  end

  def install
    args = %W[
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DFORCE_ENABLED=ON
      -DENABLE_FUSE=OFF
      -DENABLE_HTTP=ON
      -DENABLE_KRB5=ON
      -DENABLE_MACAROONS=OFF
      -DENABLE_PYTHON=ON
      -DPython_EXECUTABLE=#{python3}
      -DENABLE_READLINE=ON
      -DENABLE_SCITOKENS=OFF
      -DENABLE_TESTS=OFF
      -DENABLE_VOMS=OFF
      -DENABLE_XRDCL=ON
      -DENABLE_XRDCLHTTP=ON
      -DENABLE_XRDEC=OFF
      -DXRDCL_LIB_ONLY=OFF
      -DXRDCL_ONLY=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/xrootd -v 2>&1")

    system python3, "-c", <<~PYTHON
      import XRootD
      from XRootD import client
    PYTHON
  end
end
