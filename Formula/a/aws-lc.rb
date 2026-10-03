class AwsLc < Formula
  desc "General-purpose cryptographic library"
  homepage "https://github.com/aws/aws-lc"
  url "https://github.com/aws/aws-lc/archive/refs/tags/v5.11.0.tar.gz"
  sha256 "8cb24c6e6be1fa7ff05075c4560ca8b537a7ef48f9e6f465af4ea455794d74f4"
  license all_of: ["Apache-2.0", "ISC", "OpenSSL", "MIT", "BSD-3-Clause"]

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "953eaacee9db3c579b74deb3c760a823e4818861447f28e0ea410e7c2aacbe19"
  end

  depends_on "bindgen" => :build
  depends_on "cmake" => :build
  depends_on "go" => :build

  uses_from_macos "llvm" => :build # for libclang
  uses_from_macos "perl" => :build

  on_macos do
    keg_only "it conflicts with OpenSSL"
  end

  deny_network_access!

  def install
    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DGENERATE_RUST_BINDINGS=ON
    ]
    # Build with ENABLE_DIST_PKG to avoid conflicting with OpenSSL symbols and files,
    # https://github.com/aws/aws-lc/blob/main/BUILDING.md#distribution-packaging-mode
    args << "-DENABLE_DIST_PKG=ON" if OS.linux?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args

    # The jitter entropy collector must be built without optimisations
    ENV.O0 { system "cmake", "--build", "build", "--target", "jitterentropy" }

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249"
    bssl = OS.mac? ? "bssl" : "aws-lc-bssl"
    output = shell_output("#{bin/bssl} sha256sum testfile.txt")
    assert_match expected_checksum, output
  end
end
