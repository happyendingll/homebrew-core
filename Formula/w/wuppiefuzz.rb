class Wuppiefuzz < Formula
  desc "Coverage-guided REST API fuzzer developed on top of LibAFL"
  homepage "https://github.com/TNO-S3/WuppieFuzz"
  url "https://github.com/TNO-S3/WuppieFuzz/releases/download/v1.8.0/source.tar.gz"
  sha256 "8405309fc4b51fbabda282540c25605a00e741b4f3c0c73fe8e7a594ed23ca9c"
  license "Apache-2.0"
  revision 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "c82ddeb5f654c7497f13667ba5d9d43ee22d59bb248a1e96e08f1c1a8ee16c73"
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

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
    system "cargo", "metadata", "--locked", "--format-version=1"
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
    assert_match "Error: Could not extract server URL from API spec", output
  end
end
