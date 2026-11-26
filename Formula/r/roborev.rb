class Roborev < Formula
  desc "Background code review with AI agents"
  homepage "https://roborev.io"
  url "https://github.com/kenn-io/roborev/releases/download/v0.76.0/roborev_0.76.0_source.tar.gz"
  sha256 "ab4bad18702c654a913d4672e0c8829ac55bd3ace8956bd41f2739e0a335afd1"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "930046a96c97abbe39071193c69d98f4a4af956e77efda6ab333727cc700d43a"
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
