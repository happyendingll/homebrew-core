class Seaweedfs < Formula
  desc "Fast distributed storage system"
  homepage "https://seaweedfs.com"
  url "https://github.com/seaweedfs/seaweedfs.git",
      tag:      "4.47",
      revision: "c5073360007d28385a33426a42ac3e4ec504c5a3"
  license "Apache-2.0"
  head "https://github.com/seaweedfs/seaweedfs.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "e8222cc69a6efe7ea8c218e6b0a668aa30137a81cce676f47027fcec5ae266d5"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X github.com/seaweedfs/seaweedfs/weed/util.COMMIT=#{Utils.git_head}]
    system "go", "build", *std_go_args(ldflags:, output: bin/"weed"), "./weed"
    (var/"seaweedfs").mkpath
  end

  service do
    run [opt_bin/"weed", "server", "-dir=#{var}/seaweedfs", "-s3"]
    keep_alive true
    error_log_path var/"log/seaweedfs.log"
    log_path var/"log/seaweedfs.log"
    working_dir var
  end

  test do
    # Start master and volume servers separately as `weed server` links them via `/tmp` sockets the sandbox denies
    master_port = free_port
    volume_port = free_port
    master_grpc_port = free_port
    volume_grpc_port = free_port

    spawn bin/"weed", "master", "-ip=127.0.0.1", "-port=#{master_port}", "-port.grpc=#{master_grpc_port}",
          "-mdir=#{testpath}"
    spawn bin/"weed", "volume", "-ip=127.0.0.1", "-port=#{volume_port}", "-port.grpc=#{volume_grpc_port}",
          "-dir=#{testpath}", "-master=127.0.0.1:#{master_port}.#{master_grpc_port}"
    sleep 30

    # Upload a test file. Volumes are created lazily, so grow one first.
    system "curl", "-s", "http://localhost:#{master_port}/vol/grow?count=1&replication=000"
    fid = JSON.parse(shell_output("curl -s http://localhost:#{master_port}/dir/assign"))["fid"]
    system "curl", "-F", "file=@#{test_fixtures("test.png")}", "http://localhost:#{volume_port}/#{fid}"

    # Download and validate uploaded test file against the original
    expected_sum = Digest::SHA256.hexdigest(File.read(test_fixtures("test.png")))
    actual_sum = Digest::SHA256.hexdigest(shell_output("curl http://localhost:#{volume_port}/#{fid}"))
    assert_equal expected_sum, actual_sum
  end
end
