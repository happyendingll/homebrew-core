class Conduit < Formula
  desc "Streams data between data stores. Kafka Connect replacement. No JVM required"
  homepage "https://conduitio.github.io/"
  url "https://github.com/ConduitIO/conduit/archive/refs/tags/v0.20.5.tar.gz"
  sha256 "3a2ebbb179a1dc06fda318b02a880c4fe2c15afe9c2c38ed1ee85c46475b95b8"
  license "Apache-2.0"
  head "https://github.com/ConduitIO/conduit.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "2ef44345a58843bc8f2350c480a799d4bfcab7b771cbe2b6b5748db8b0a28e3a"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "make", "VERSION=#{version}"
    bin.install "conduit"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/conduit --version")

    File.open("output.txt", "w") do |file|
      # redirect stdout to the file
      $stdout.reopen(file)
      pid = spawn bin/"conduit", "run", "--api.enabled", "true",
                                 "--api.grpc.address", ":0",
                                 "--api.http.address", ":0"
      sleep(5)
      # Kill process
      Process.kill("SIGKILL", pid)
    end
    assert_match "grpc API started", (testpath/"output.txt").read
    assert_match "http API started", (testpath/"output.txt").read
  end
end
