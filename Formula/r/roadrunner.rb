class Roadrunner < Formula
  desc "High-performance PHP application server, load-balancer and process manager"
  homepage "https://docs.roadrunner.dev/docs"
  url "https://github.com/roadrunner-server/roadrunner/archive/refs/tags/v3.0.1.tar.gz"
  sha256 "79cae54d8b3cc375d89f5dcdf3b89ab78d0c5ee281930936cb26de78a9171d33"
  license "MIT"
  version_scheme 1
  head "https://github.com/roadrunner-server/roadrunner.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d{1,3}(?:\.\d+)+)$/i)
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/roadrunner-server/roadrunner/v#{version.major}/internal/meta.version=#{version}
      -X github.com/roadrunner-server/roadrunner/v#{version.major}/internal/meta.buildTime=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"rr"), "./cmd/rr"

    generate_completions_from_executable(bin/"rr", shell_parameter_format: :cobra)
  end

  test do
    port = free_port
    (testpath/".rr.yaml").write <<~YAML
      # RR configuration version
      version: '3'
      rpc:
        listen: tcp://127.0.0.1:#{port}
    YAML

    output = shell_output("#{bin}/rr jobs list 2>&1", 1)
    assert_match "connect: connection refused", output

    assert_match version.to_s, shell_output("#{bin}/rr --version")
  end
end
