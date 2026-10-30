class Solidity < Formula
  desc "Contract-oriented programming language"
  homepage "https://soliditylang.org"
  url "https://github.com/argotorg/solidity/releases/download/v0.8.38/solidity_0.8.38.tar.gz"
  sha256 "a96f89d20525724acd9717032a0315466078c0176d5d13016d81f4cc81fd4115"
  license all_of: ["GPL-3.0-or-later", "MIT", "BSD-3-Clause", "Apache-2.0", "CC0-1.0"]
  compatibility_version 1

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "52a8c3203788ed25ee46e4b8d3af5e00bc933c7978314b53ed8250d610e3d6f9"
  end

  depends_on "cmake" => :build
  depends_on "fmt" => :build
  depends_on "nlohmann-json" => :build
  depends_on "range-v3" => :build
  depends_on "boost"
  depends_on "z3"

  conflicts_with "solc-select", because: "both install `solc` binaries"

  deny_network_access!

  def install
    rm_r("deps")

    # Avoid using an older deployment target than our bottle
    inreplace "CMakeLists.txt", "set(CMAKE_OSX_DEPLOYMENT_TARGET ", "# \\0"

    args = %w[
      -DBoost_USE_STATIC_LIBS=OFF
      -DSTRICT_Z3_VERSION=OFF
      -DTESTS=OFF
      -DIGNORE_VENDORED_DEPENDENCIES=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"hello.sol").write <<~SOLIDITY
      // SPDX-License-Identifier: GPL-3.0
      pragma solidity ^0.8.0;
      contract HelloWorld {
        function helloWorld() external pure returns (string memory) {
          return "Hello, World!";
        }
      }
    SOLIDITY

    output = shell_output("#{bin}/solc --bin hello.sol")
    assert_match "hello.sol:HelloWorld", output
    assert_match "Binary:", output
  end
end
