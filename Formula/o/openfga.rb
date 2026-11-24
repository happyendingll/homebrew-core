class Openfga < Formula
  desc "High performance and flexible authorization/permission engine"
  homepage "https://openfga.dev/"
  url "https://github.com/openfga/openfga/archive/refs/tags/v1.23.0.tar.gz"
  sha256 "1b7e22145ade674dd2cc93a56f9d2e9ba055b6a939566a57190c3508f7087ff2"
  license "Apache-2.0"
  head "https://github.com/openfga/openfga.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "74c6585eb92a278761615aa3045b75fee9c14d0e46fdb3bfe78db8388cd8d2c6"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/openfga/openfga/internal/build.Version=#{version}
      -X github.com/openfga/openfga/internal/build.Commit=#{tap.user}
      -X github.com/openfga/openfga/internal/build.Date=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/openfga"

    generate_completions_from_executable(bin/"openfga", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/openfga version 2>&1")

    port = free_port
    with_test_process(bin/"openfga", "run", "--playground-enabled", "--playground-port", port.to_s) do
      sleep 3
      output = shell_output("curl -s http://localhost:#{port}/playground")
      assert_match "title=\"Embedded Playground\"", output
    end
  end
end
