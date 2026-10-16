class Alive2 < Formula
  desc "Automatic verification of LLVM optimizations"
  homepage "https://github.com/AliveToolkit/alive2"
  license "MIT"
  revision 8
  head "https://github.com/AliveToolkit/alive2.git", branch: "master"

  stable do
    url "https://github.com/AliveToolkit/alive2.git",
        tag:      "v21.0",
        revision: "913e1556032ee70a9ebf147b5a0c7e10086b7490"

    # Backport fix for LLVM 22
    patch do
      url "https://github.com/AliveToolkit/alive2/commit/a86aaa0ea44c5671ce3e998ec6d422feaa95b236.patch?full_index=1"
      sha256 "6645b59d29e7a4bbe45e91f57391cf9d4e5dbc27ba99a93c89ad13b14d57a7c4"
      type :backport
      resolves "https://github.com/AliveToolkit/alive2/pull/1265"
    end

    # Backport commit for LLVM 23
    patch do
      url "https://github.com/AliveToolkit/alive2/commit/155386f37536a8f64d78c0ef7d52f7d3f1926cd1.patch?full_index=1"
      sha256 "01b319ccbfdb2a8c2a98bd2d5fc2e5b9564511f2738afae1b8d125d014af1678"
      type :backport
      resolves "https://github.com/AliveToolkit/alive2/pull/1309"
    end
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "e1c4edff54cd5e70c6230fbffd2f6f9c589e9b7e60aa2a01ccc0e30ca8ac4435"
    sha256 cellar: :any, arm64_tahoe:       "e9a3b24a72797f700bc0e13b64c81f9e528cd5efe6339e436ac85828275a1edb"
    sha256 cellar: :any, arm64_sequoia:     "c4736341979f3aefbb3e22d6196c865b37fc3c5811e7e6a2ac4dce4b809dca75"
    sha256 cellar: :any, arm64_linux:       "4c07a0ee1a8439fffdf7de8dc499acb3d64b1d61382b8369ec9c653f78f3fa58"
    sha256 cellar: :any, x86_64_linux:      "822b6dc26e4cffef0f476e2c85d9ecf80b2c8d05dd843b407701a8e2453969c0"
  end

  depends_on "cmake" => :build
  depends_on "re2c" => :build
  depends_on "hiredis"
  depends_on "llvm"
  depends_on "z3"
  depends_on "zstd"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  fails_with :clang do
    build 1500
    cause "error: reference to local binding 'src_data' declared in enclosing function 'IR::State::copyUBFromBB'"
  end

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", "-DBUILD_LLVM_UTILS=ON", "-DBUILD_TV=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      int main(void) { return 0; }
    C

    clang = formula_opt_bin("llvm")/"clang"
    system clang, "-O3", "test.c", "-S", "-emit-llvm",
                  "-fpass-plugin=#{lib/shared_library("tv")}",
                  "-Xclang", "-load",
                  "-Xclang", lib/shared_library("tv")
  end
end
