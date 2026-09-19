class Pitchfork < Formula
  desc "CLI for managing daemons with a focus on developer experience"
  homepage "https://pitchfork.jdx.dev"
  url "https://github.com/jdx/pitchfork/archive/refs/tags/v2.26.0.tar.gz"
  sha256 "9bf37146608c37bc9ff3fe1f7f09d40acdbeb7fcad70873fa5ebff9bd07dca0e"
  license "MIT"
  head "https://github.com/jdx/pitchfork.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "b85cd291b16737491c6681ba3fd152794ddafc40c574563c5bfc8cd1ef7be361"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f3cd3d00a8f4da229a40a25154ee44e9783e3b0e9b15e983adb06733d81fc525"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "97af6dd0f459d70906ddf352a0fbf73b9b71b1f431ca6c91c09a15da75617738"
    sha256 cellar: :any,                 arm64_linux:       "3c57f0455bf871041daae87ef98f8b27c651c84144115ce1da7d6c8e98fca083"
    sha256 cellar: :any,                 x86_64_linux:      "47f9cd23d39f3b4231b8e6fdaae54d24dc5fff2de217c653bcbd7f3a8dbe4263"
  end

  depends_on "node" => :build
  depends_on "pnpm" => :build
  depends_on "rust" => :build
  depends_on "usage"

  def install
    cd "ui" do
      system "pnpm", "install", "--frozen-lockfile"
      system "pnpm", "build"
    end

    system "cargo", "install", *std_cargo_args
    generate_completions_from_executable(bin/"pitchfork", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pitchfork --version")

    system bin/"pitchfork", "daemons", "add", "brewtest", "--run", "echo brewed", "--ready-output", "brewed"
    config = (testpath/"pitchfork.toml").read
    assert_match 'run = "echo brewed"', config
    assert_match 'ready_output = "brewed"', config

    port = free_port
    pid = spawn bin/"pitchfork", "supervisor", "run", "--web-port", port.to_s
    sleep 1
    assert_match "<title>Pitchfork</title>", shell_output("curl -s http://127.0.0.1:#{port}")
  ensure
    Process.kill("TERM", pid) if pid
  end
end
