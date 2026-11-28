class Victorialogs < Formula
  desc "Open source user-friendly database for logs from VictoriaMetrics"
  homepage "https://docs.victoriametrics.com/victorialogs/"
  url "https://github.com/VictoriaMetrics/VictoriaLogs/archive/refs/tags/v1.55.0.tar.gz"
  sha256 "80bdd76a01250991389dc82c48c4d813c44626bf01bff46f0b0811098c57e129"
  license "Apache-2.0"

  # The Git tags are interspersed with higher versions like 1.118.0, so we check
  # the "latest" release instead of the Git tags.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "6e3235b478f9c65d42fad5091614e5f22cffdca056f7186caf14fb5fa53f6e4d"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/VictoriaMetrics/VictoriaMetrics/lib/buildinfo.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:, output: bin/"victoria-logs"), "./app/victoria-logs"
  end

  service do
    run [
      opt_bin/"victoria-logs",
      "-httpListenAddr=127.0.0.1:9428",
      "-storageDataPath=#{var}/victorialogs-data",
    ]
    keep_alive false
    log_path var/"log/victoria-logs.log"
    error_log_path var/"log/victoria-logs.err.log"
  end

  test do
    http_port = free_port

    with_test_process(bin/"victoria-logs",
                      "-httpListenAddr=127.0.0.1:#{http_port}",
                      "-storageDataPath=#{testpath}/victorialogs-data") do
      sleep 5
      assert_match "VictoriaLogs", shell_output("curl -s 127.0.0.1:#{http_port}")

      assert_match version.to_s, shell_output("#{bin}/victoria-logs --version")
    end
  end
end
