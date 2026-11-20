class NodeExporter < Formula
  desc "Prometheus exporter for machine metrics"
  homepage "https://prometheus.io/"
  url "https://github.com/prometheus/node_exporter/archive/refs/tags/v1.13.1.tar.gz"
  sha256 "329f02a71a0bb007e7e700f12ff724b019415730fb60bdf724bf2b28f3d5f223"
  license "Apache-2.0"
  head "https://github.com/prometheus/node_exporter.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "03e895c749c4c8c97df33f438f6df9a420c6ca52acb9b9c34093a6e2e789923c"
  end

  depends_on "go" => :build

  # `test do` block runs a local exporter server
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/prometheus/common/version.Version=#{version}
      -X github.com/prometheus/common/version.BuildUser=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:)

    touch etc/"node_exporter.args"

    (bin/"node_exporter_brew_services").write <<~BASH
      #!/bin/bash
      exec #{bin}/node_exporter $(<#{etc}/node_exporter.args)
    BASH
  end

  def caveats
    <<~EOS
      When run from `brew services`, `node_exporter` is run from
      `node_exporter_brew_services` and uses the flags in:
        #{etc}/node_exporter.args
    EOS
  end

  service do
    run [opt_bin/"node_exporter_brew_services"]
    keep_alive false
    log_path var/"log/node_exporter.log"
    error_log_path var/"log/node_exporter.err.log"
  end

  test do
    assert_match "node_exporter", shell_output("#{bin}/node_exporter --version 2>&1")

    spawn bin/"node_exporter"
    sleep 2
    assert_match "# HELP", shell_output("curl -s localhost:9100/metrics")
  end
end
