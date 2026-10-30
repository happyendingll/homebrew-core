class InfluxdbCli < Formula
  desc "CLI for managing resources in InfluxDB v2"
  homepage "https://influxdata.com/time-series-platform/influxdb/"
  url "https://github.com/influxdata/influx-cli/archive/refs/tags/v2.9.1.tar.gz"
  sha256 "5a16c3866640518339a31fe03a25c341f6f9ae5c2fbd149c5bc47e95e6e9e8b9"
  license "MIT"
  head "https://github.com/influxdata/influx-cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?((?!9\.9\.9)\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "bf4ae6785b9ec36429dccb6b17560e5e163d98411932ce0270fcb0485ace663d"
  end

  depends_on "go" => :build
  depends_on "influxdb@2" => :test

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    # Although project no longer uses GoReleaser, the defines were kept the same
    system "go", "build", *std_go_args(output: bin/"influx", ldflags: :goreleaser), "./cmd/influx"

    generate_completions_from_executable(bin/"influx", "completion", shells: [:bash, :zsh])
  end

  test do
    # Boot a test server.
    influxd_port = free_port
    influxd_args = %W[
      --bolt-path=#{testpath}/influxd.bolt
      --engine-path=#{testpath}/engine
      --http-bind-address=:#{influxd_port}
      --log-level=error
    ]
    influxd = spawn formula_opt_bin("influxdb@2")/"influxd", *influxd_args
    sleep 30

    # Configure the CLI for the test env.
    influx_host = "http://localhost:#{influxd_port}"
    cli_configs_path = "#{testpath}/influx-configs"
    ENV["INFLUX_HOST"] = influx_host
    ENV["INFLUX_CONFIGS_PATH"] = cli_configs_path

    # Check that the CLI can connect to the server.
    assert_match "OK", shell_output("#{bin}/influx ping")

    # Perform initial DB setup.
    system bin/"influx", "setup", "-u", "usr", "-p", "fakepassword", "-b", "bkt", "-o", "org", "-f"

    # Assert that initial resources show in CLI output.
    assert_match "usr", shell_output("#{bin}/influx user list")
    assert_match "bkt", shell_output("#{bin}/influx bucket list")
    assert_match "org", shell_output("#{bin}/influx org list")
  ensure
    Process.kill("TERM", influxd)
    Process.wait influxd
  end
end
