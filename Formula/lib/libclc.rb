class Libclc < Formula
  desc "Implementation of the library requirements of the OpenCL C programming language"
  homepage "https://libclc.llvm.org/"
  url "https://github.com/llvm/llvm-project/releases/download/llvmorg-23.1.4/llvm-project-23.1.4.src.tar.xz"
  sha256 "819ecf7351f1a66f76b2d701d8942faaf5faeb324cb90c9d5b090de142434bb2"
  license "Apache-2.0" => { with: "LLVM-exception" }
  compatibility_version 1

  livecheck do
    url :stable
    regex(/^llvmorg[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "eb9bbf293d9c97e3a65d4b4a232c2fedfcbd09b254056362c07ec5d59fa618f9"
  end

  depends_on "cmake" => :build
  depends_on "llvm" => [:build, :test]
  depends_on "spirv-llvm-translator" => :build

  def install
    targets = %w[
      amdgcn-amd-amdhsa-llvm
      nvptx64-nvidia-cuda
      spirv32-unknown-unknown
      spirv64-unknown-unknown
      spirv32-unknown-vulkan
      spirv64-unknown-vulkan
    ]

    # Targets are cross-compiled and incompatible with shim-injected flags like `-march`/`-mbranch-protection`
    args = ["-DCMAKE_CLC_COMPILER=#{formula_opt_bin("llvm")}/clang"]

    targets.each do |target|
      builddir = "build-#{target}"
      system "cmake", "-S", "libclc", "-B", builddir, "-DLLVM_DEFAULT_TARGET_TRIPLE=#{target}", *args, *std_cmake_args
      system "cmake", "--build", builddir
      system "cmake", "--install", builddir
    end
  end

  test do
    # https://github.com/llvm/llvm-project/blob/main/libclc/test/integer/add_sat.cl
    (testpath/"add_sat.cl").write <<~C
      char test_char(char x, char y) {
        return add_sat(x, y);
      }
    C

    target = "amdgcn-amd-amdhsa-llvm"
    clang_args = %W[
      --target=#{target}
      -mcpu=gfx900
      --libclc-lib=:#{share}/clc/#{target}/libclc.bc
      -cl-std=CL3.0
      -O2
      -fno-discard-value-names
      -emit-llvm
      -S
    ]
    llvm_bin = formula_opt_bin("llvm")

    system llvm_bin/"clang", *clang_args, "./add_sat.cl"
    ir = File.read("add_sat.ll")
    assert_match("target triple = \"#{target}\"", ir)
    assert_match(/define .* @test_char\(/, ir)
  end
end
