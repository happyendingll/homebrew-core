class Chronograf < Formula
  desc "Open source monitoring and visualization UI for the TICK stack"
  homepage "https://docs.influxdata.com/chronograf/latest/"
  url "https://github.com/influxdata/chronograf/archive/refs/tags/1.11.5.tar.gz"
  sha256 "d8ad3f9ed113d4e44a48cb7459302bd0e011c0ed2117df2d4d4be1111f122362"
  license "AGPL-3.0-or-later"
  head "https://github.com/influxdata/chronograf.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "51f609a3c997e3b13e58e21f45be8dc13d2f7b7320167a7a6dbebf7511154b30"
  end

  depends_on "go" => :build
  depends_on "node" => :build
  depends_on "pkg-config-wrapper" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "yarn" => :build
  depends_on "influxdb"
  depends_on "kapacitor"

  def install
    ENV["PKG_CONFIG"] = formula_opt_bin("pkg-config-wrapper")/"pkg-config-wrapper"
    ENV["CGO_ENABLED"] = "1" if OS.linux?
    ENV["npm_config_build_from_source"] = "true"

    system "yarn", "--cwd=ui", "install"
    system "yarn", "--cwd=ui", "build", "--no-cache"

    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/chronograf"
    system "go", "build", *std_go_args(ldflags: :goreleaser, output: bin/"chronoctl"), "./cmd/chronoctl"
  end

  service do
    run opt_bin/"chronograf"
    keep_alive true
    error_log_path var/"log/chronograf.log"
    log_path var/"log/chronograf.log"
    working_dir var
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/chronograf --version")

    port = free_port
    pid = spawn bin/"chronograf", "--port=#{port}"
    output = shell_output("curl -s --retry 5 --retry-connrefused 0.0.0.0:#{port}/chronograf/v1/")
    assert_match "/chronograf/v1/layouts", output
  ensure
    Process.kill("SIGTERM", pid)
    Process.wait(pid)
  end
end
