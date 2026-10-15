class Conduit < Formula
  desc "Streams data between data stores. Kafka Connect replacement. No JVM required"
  homepage "https://conduitio.github.io/"
  url "https://github.com/ConduitIO/conduit/archive/refs/tags/v0.20.1.tar.gz"
  sha256 "d641d56faeb34da6db1bb82edcc86749a1629d7218f5d677d796829570503cd9"
  license "Apache-2.0"
  head "https://github.com/ConduitIO/conduit.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "bbc5633d686be9434b5ce3057b7a3db7673c5ca2ba2cdd3f2dd804db19c68da6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "34d98f04a3767146f09c354e307d8e8b4f8874d96aabf33bf56f6ec80c8faad9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "01b6409b2961e5c68a26f053631ffff42abf69d0ba612fbba5b2292ae5b891b9"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "cf9930a4b92ae65e516d83f98269df03b9aa4cc2905d510e8368b5e9ff0aff2c"
    sha256 cellar: :any,                 x86_64_linux:      "7a8b56ff60100dde83a3a2d809ac2d7ded98d4f8ca23230703c1ede6ef712cd6"
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
