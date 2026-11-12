class Roborev < Formula
  desc "Background code review with AI agents"
  homepage "https://roborev.io"
  url "https://github.com/kenn-io/roborev/releases/download/v0.75.0/roborev_0.75.0_source.tar.gz"
  sha256 "b033f52eaa9d03d4bb646e7dee7fee57c0ba2db0145797f3bed311ba6c367bf3"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "07cc33eb81eb8f3752d2f1c6b2111d18a0522b2d81cd453b15ed57d41db729e1"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def install
    ldflags = %W[
      -X go.kenn.io/roborev/internal/version.Version=#{version}
      -X go.kenn.io/roborev/internal/version.Distribution=homebrew
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/roborev"
  end

  service do
    run [opt_bin/"roborev", "daemon", "run"]
    keep_alive true
  end

  test do
    ENV["ROBOREV_DATA_DIR"] = testpath
    (testpath/"config.toml").write "server_addr = \"127.0.0.1:#{free_port}\"\n"

    assert_match "brew upgrade roborev", shell_output("#{bin}/roborev update 2>&1", 1)

    status = JSON.parse(shell_output("#{bin}/roborev status --json"))
    assert_equal true, status["running"]
    assert_path_exists testpath/"reviews.db"
    page = shell_output("curl -fsSL -H 'Accept: text/html' #{status.fetch("web_url")}")
    assert_match 'name="roborev-web-distribution" content="production"', page
  ensure
    system bin/"roborev", "daemon", "stop"
  end
end
