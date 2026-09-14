class ProtocGenGrpcSwift < Formula
  desc "Protoc plugin for generating gRPC Swift stubs"
  homepage "https://github.com/grpc/grpc-swift-protobuf"
  url "https://github.com/grpc/grpc-swift-protobuf/archive/refs/tags/2.4.1.tar.gz"
  sha256 "536c1b0c5dfe8efa604c30bb2b831b49e765aa212b1180acda3d630714187197"
  license "Apache-2.0"
  version_scheme 1
  head "https://github.com/grpc/grpc-swift-protobuf.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "67aa39a3e5862f78d4721303f87783fb7e17486baf9c4aa05f21b1391847a958"
  end

  depends_on "protobuf"
  depends_on "swift-protobuf"

  uses_from_macos "swift" => :build

  on_macos do
    depends_on xcode: ["15.0", :build]
    # https://swiftpackageindex.com/grpc/grpc-swift/documentation/grpccore/compatibility#Platforms
    depends_on macos: :sequoia
  end

  def install
    system "swift", "build", "--product", "protoc-gen-grpc-swift-2", *std_swift_args
    bin.install ".build/release/protoc-gen-grpc-swift-2"
  end

  test do
    (testpath/"echo.proto").write <<~PROTO
      syntax = "proto3";
      service Echo {
        rpc Get(EchoRequest) returns (EchoResponse) {}
        rpc Expand(EchoRequest) returns (stream EchoResponse) {}
        rpc Collect(stream EchoRequest) returns (EchoResponse) {}
        rpc Update(stream EchoRequest) returns (stream EchoResponse) {}
      }
      message EchoRequest {
        string text = 1;
      }
      message EchoResponse {
        string text = 1;
      }
    PROTO
    system formula_opt_bin("protobuf")/"protoc", "echo.proto", "--grpc-swift-2_out=."
    assert_path_exists testpath/"echo.grpc.swift"
  end
end
