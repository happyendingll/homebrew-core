class Conduit < Formula
  desc "Streams data between data stores. Kafka Connect replacement. No JVM required"
  homepage "https://conduitio.github.io/"
  url "https://github.com/ConduitIO/conduit/archive/refs/tags/v0.22.0.tar.gz"
  sha256 "4c1d4e556a404efbde124cc827ce874ddd2d4ca55cfe22f5734ffc19042ca730"
  license "Apache-2.0"
  head "https://github.com/ConduitIO/conduit.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "86825e6b89fca8f4ada79bb1a04966e1e8d1acbba85cf2b96ef2a062402c154b"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    # Drop the test files the revert patch deletes but `patch` leaves empty
    %w[pkg/lifecycle-poc/archv2_batching_boot_test.go pkg/provisioning/boot_start_test.go].each do |f|
      rm f if File.empty?(f)
    end

    system "make", "VERSION=#{version}"
    bin.install "conduit"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/conduit --version")

    File.open("output.txt", "w") do |file|
      # redirect stdout to the file
      $stdout.reopen(file)
      pid = spawn bin/"conduit", "run", "--api.enabled", "true",
                                 "--api.grpc.address", "127.0.0.1:0",
                                 "--api.http.address", "127.0.0.1:0"
      sleep(5)
      # Kill process
      Process.kill("SIGKILL", pid)
    end
    assert_match "grpc API started", (testpath/"output.txt").read
    assert_match "http API started", (testpath/"output.txt").read
  end
end
