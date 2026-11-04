class Vulcain < Formula
  desc "Fast and idiomatic client-driven REST APIs"
  homepage "https://vulcain.rocks/"
  url "https://github.com/dunglas/vulcain/archive/refs/tags/v1.4.6.tar.gz"
  sha256 "e65e224349dc632efd8f1b01b965837537f93ccb4af27a359e26340faf33bc8a"
  license "AGPL-3.0-only"
  head "https://github.com/dunglas/vulcain.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "a70c30e7a2cc3ec428e23980eb392874ec6d88706a92b12a2aa4558b03c1848a"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download", "-C", "caddy"
  end

  def install
    ldflags = "-X github.com/caddyserver/caddy/v2.CustomVersion=Vulcain.rocks.#{version}"

    cd "caddy" do
      system "go", "build", *std_go_args(ldflags:, tags: "nobadger,nomysql,nopgx"), "./vulcain"
    end
  end

  service do
    run [opt_bin/"vulcain", "run", "--config", etc/"Caddyfile"]
    keep_alive true
    error_log_path var/"log/vulcain.log"
    log_path var/"log/vulcain.log"
    environment_variables(
      XDG_DATA_HOME: "#{HOMEBREW_PREFIX}/var/lib",
      HOME:          "#{HOMEBREW_PREFIX}/var/lib",
    )
  end

  test do
    port = free_port

    assert_match version.to_s, shell_output("#{bin}/vulcain version")

    (testpath/"Caddyfile").write <<~EOS
      http://127.0.0.1:#{port} {
        respond "Vulcain API"
      }
    EOS

    pid = spawn bin/"vulcain", "run", "--config", testpath/"Caddyfile"

    sleep 2

    assert_match "Vulcain API", shell_output("curl -s http://127.0.0.1:#{port}")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
