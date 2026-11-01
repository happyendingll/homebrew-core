class SpirvLlvmTranslator < Formula
  desc "Tool and a library for bi-directional translation between SPIR-V and LLVM IR"
  homepage "https://github.com/KhronosGroup/SPIRV-LLVM-Translator"
  url "https://github.com/KhronosGroup/SPIRV-LLVM-Translator/archive/refs/tags/v23.1.3.tar.gz"
  sha256 "9ed57de3f31c575c836bef8f05ce5dfa98a8d80e64d948a02aac83c2e124f842"
  license "Apache-2.0" => { with: "LLVM-exception" }
  compatibility_version 2

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "488bdd6f2da1bb22e410adc8a9fa7dd499fbb17a89fac3e3c477be281d70d865"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "llvm"

  resource "spirv-headers" do
    # Match the upstream spirv-headers-tag.conf.
    url "https://github.com/KhronosGroup/SPIRV-Headers/archive/cb42dec3830d3ac67fa449ecdc0c0f73d5e74498.tar.gz"
    version "cb42dec3830d3ac67fa449ecdc0c0f73d5e74498"
    sha256 "117010e525fe36b1ce006e0e58a6e0a3b415aabc9179d912b92737f41f3f994f"

    livecheck do
      url "https://raw.githubusercontent.com/KhronosGroup/SPIRV-LLVM-Translator/refs/tags/v#{LATEST_VERSION}/spirv-headers-tag.conf"
      regex(/^([0-9a-f]{40})$/i)
    end
  end

  def llvm
    deps.map(&:to_formula).find { |f| f.name.match?(/^llvm(@\d+)?$/) }
  end

  def install
    resource("spirv-headers").stage(buildpath/"spirv-headers")
    ENV.append "LDFLAGS", "-Wl,-rpath,#{rpath(target: llvm.opt_lib)}" if OS.linux?
    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_SHARED_LIBS=ON",
                    "-DCCACHE_ALLOWED=OFF",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}",
                    "-DLLVM_BUILD_TOOLS=ON",
                    "-DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=#{buildpath}/spirv-headers",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.ll").write <<~LLVM
      target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
      target triple = "spir64-unknown-unknown"

      define spir_kernel void @foo() {
        ret void
      }
    LLVM
    system llvm.opt_bin/"llvm-as", "test.ll"
    system bin/"llvm-spirv", "test.bc"
    assert_path_exists testpath/"test.spv"
  end
end
