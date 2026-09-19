class Wuppiefuzz < Formula
  desc "Coverage-guided REST API fuzzer developed on top of LibAFL"
  homepage "https://github.com/TNO-S3/WuppieFuzz"
  url "https://github.com/TNO-S3/WuppieFuzz/releases/download/v1.7.1/source.tar.gz"
  sha256 "93e3c143b90d552a2620211b866176cedfea58d263bf75331f2da550a55996f3"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "95a5ed11f2b0ff56dbcc7c2f51a0d88e72795f407fb58312ba4087950dadd1b4"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "z3"

  uses_from_macos "llvm" => :build # for libclang
  uses_from_macos "sqlite"

  on_linux do
    depends_on "openssl@4" => :build
  end

  def install
    rm ".cargo/config.toml" # macOS `-stack_size` flag breaks proc-macro linking
    ENV["Z3_LIBRARY_PATH_OVERRIDE"] = formula_opt_lib("z3")
    ENV["Z3_SYS_Z3_HEADER"] = formula_opt_include("z3")/"z3.h"
    system "cargo", "install", "--no-default-features", *std_cargo_args(features: ["std"])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/wuppiefuzz version")

    (testpath/"openapi.yaml").write <<~YAML
      openapi: 3.0.0
    YAML

    output = shell_output("#{bin}/wuppiefuzz fuzz openapi.yaml 2>&1", 1)
    assert_match "Error: Error parsing OpenAPI-file at openapi.yaml", output
  end
end
