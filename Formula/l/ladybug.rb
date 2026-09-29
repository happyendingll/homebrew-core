class Ladybug < Formula
  desc "Embedded graph database built for query speed and scalability"
  homepage "https://ladybugdb.com/"
  url "https://github.com/LadybugDB/ladybug/archive/refs/tags/v0.21.0.tar.gz"
  sha256 "b367872a9d423b6f4e26b073dce7ba60dacedfba16e876d32d608b5f4977ef63"
  license "MIT"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "889f4fd8adeabe08baa8ae2cf57eb6211fd6e59e8e6524b8cfc49a8514525d5c"
    sha256 cellar: :any, arm64_tahoe:       "bbe62a037403115f4eca91c06ba17628b0378b56a06c3b926af3a553387685ce"
    sha256 cellar: :any, arm64_sequoia:     "e42bf817f74eab555bb3062c6603d67b2b0f056131fdee6a9ecc5ffcab283bef"
    sha256 cellar: :any, arm64_linux:       "66a0a956a94291780e8f354183ccefa8d04b888dec59e9316d45b16a0aa016aa"
    sha256 cellar: :any, x86_64_linux:      "00d46c85f1ac932559e73f4655ce89bb061d035062d896bda7f8a82c93e17855"
  end

  depends_on "cmake" => :build
  depends_on "openssl@4"

  uses_from_macos "python" => :build

  on_macos do
    depends_on "llvm" => :build if DevelopmentTools.clang_build_version <= 1600
  end

  fails_with :clang do
    build 1600
    cause "Requires C+++20 support for `std::atomic_ref`"
  end

  fails_with :gcc do
    version "12"
    cause "Requires C++20 std::format, https://gcc.gnu.org/gcc-13/changes.html#libstdcxx"
  end

  deny_network_access!

  def install
    args = %W[-DCMAKE_INSTALL_RPATH=#{rpath}]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Remove unwanted headers and libraries for `cppjieba`
    rm_r Dir["{#{include},#{share}}/cppjieba/*"]
  end

  test do
    # Upstream versioning up to patch version, so skip for 4th number in version
    assert_match version.major_minor_patch.to_s, shell_output("#{bin}/lbug --version")

    # Test basic query functionality
    output = pipe_output("#{bin}/lbug -m csv -s", "UNWIND [1, 2, 3, 4, 5] as i return i;")
    assert_match "i", output
    assert_match "1", output
    assert_match "2", output
    assert_match "3", output
    assert_match "4", output
    assert_match "5", output
  end
end
