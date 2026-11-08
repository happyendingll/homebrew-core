class Ktea < Formula
  desc "Kafka TUI client"
  homepage "https://github.com/jonas-grgt/ktea"
  url "https://github.com/jonas-grgt/ktea/archive/refs/tags/v0.9.2.tar.gz"
  sha256 "ecf0eeadfc95aae9c1d812d4f52841dc8d5370cad72101cd33f5cf4d827acb3f"
  license "Apache-2.0"
  head "https://github.com/jonas-grgt/ktea.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "3cceca5e9a6abdb43a9a4844ac35de963b913ccd4b83946b985f4ec5871b98aa"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(tags: "prd"), "./cmd/ktea"
  end

  test do
    require "expect"
    require "io/console"
    require "io/wait"
    require "pty"
    require "timeout"

    config_file = testpath/".config/ktea/config.yaml"
    config_file.dirname.mkpath
    config_file.write "{clusters: [], plainFonts: true, theme: dracula}\n"

    r, w, pid = PTY.spawn({ "TERM" => "xterm-256color" }, bin/"ktea")
    r.winsize = [30, 120]
    r.expect(/Clusters/, 10)
    w.write "\u000c" # Open Settings.
    r.expect(/Themes/, 10)
    w.write "\e[H\r" # Apply the first built-in theme.
    Timeout.timeout(10) do
      r.readpartial(4096) until YAML.load_file(config_file)["theme"] == "catppuccin"
      r.read_nonblock(4096) while r.wait_readable(0.1)
    end
    assert_equal({ "clusters" => [], "plainFonts" => true, "theme" => "catppuccin" },
                 YAML.load_file(config_file))
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
