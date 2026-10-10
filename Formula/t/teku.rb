class Teku < Formula
  desc "Java Implementation of the Ethereum 2.0 Beacon Chain"
  homepage "https://docs.teku.consensys.net/"
  url "https://github.com/ConsenSys/teku.git",
      tag:      "26.10.0",
      revision: "a46f9e1e3679e4c2707d27447628d07a6c67b600"
  license "Apache-2.0"
  head "https://github.com/ConsenSys/teku.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "0d6e06a611ef636d76eab895b60d8ae45268e8aacd41d54d2c4e3476d28ba776"
  end

  depends_on "gradle" => :build
  depends_on "openjdk@25"

  def install
    ENV["JAVA_HOME"] = Language::Java.java_home("25")

    system "gradle", "installDist", "--no-daemon"
    libexec.install Dir["build/install/teku/*"]
    (bin/"teku").write_env_script libexec/"bin/teku", Language::Java.overridable_java_home_env("25")
  end

  test do
    assert_match "teku/", shell_output("#{bin}/teku --version")

    rest_port = free_port
    test_args = %W[
      --network=minimal
      --Xinterop-enabled
      --Xinterop-number-of-validators=8
      --rest-api-enabled
      --rest-api-port=#{rest_port}
      --p2p-enabled=false
      --data-path=#{testpath}
    ]
    spawn bin/"teku", *test_args
    sleep 15

    output = shell_output("curl -sS -XGET http://127.0.0.1:#{rest_port}/eth/v1/node/syncing")
    assert_match "is_syncing", output
  end
end
