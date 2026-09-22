class Buffa < Formula
  desc "Pure-Rust Protocol Buffers implementation with editions support"
  homepage "https://github.com/anthropics/buffa"
  url "https://github.com/anthropics/buffa/archive/refs/tags/v0.9.2.tar.gz"
  sha256 "318b363643469c50517cabed7e28c8950f895457b1165fca84f09ca884121d49"
  license "Apache-2.0"
  head "https://github.com/anthropics/buffa.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "67363a93548ee89422446cd6516da7c99bb9aa752d9a5bcf6e375e2449eefb89"
  end

  depends_on "rust" => :build
  depends_on "protobuf"

  def install
    system "cargo", "install", *std_cargo_args(path: "protoc-gen-buffa")
    system "cargo", "install", *std_cargo_args(path: "protoc-gen-buffa-packaging")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/protoc-gen-buffa --version")

    (testpath/"sample.proto").write <<~PROTO
      syntax = "proto3";
      package example.v1;

      message Greeting {
        string message = 1;
      }
    PROTO

    (testpath/"gen").mkpath
    system "protoc",
           "--plugin=protoc-gen-buffa=#{bin}/protoc-gen-buffa",
           "--plugin=protoc-gen-buffa-packaging=#{bin}/protoc-gen-buffa-packaging",
           "--buffa_out=gen",
           "--buffa-packaging_out=gen",
           "sample.proto"

    assert_match "pub struct Greeting", (testpath/"gen/sample.rs").read
    assert_match "pub mod example", (testpath/"gen/mod.rs").read
  end
end
