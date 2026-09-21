class Ctrld < Formula
  desc "Highly configurable, multi-protocol DNS forwarding proxy"
  homepage "https://github.com/Control-D-Inc/ctrld"
  url "https://github.com/Control-D-Inc/ctrld/archive/refs/tags/v1.5.7.tar.gz"
  sha256 "6f5c1b95c41260911ff64c7074333fffcb9b5122cc9826075cd8ee51024cc0bf"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "b261cbda6d253f4b1727df35004aab4918db38637f3ba2b913216d77733b143f"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/Control-D-Inc/ctrld/cmd/cli.version=#{version}
      -X github.com/Control-D-Inc/ctrld/cmd/cli.commit=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/ctrld"
    generate_completions_from_executable(bin/"ctrld", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ctrld --version")

    output_log = testpath/"output.log"
    pid = spawn bin/"ctrld", "start", [:out, :err] => output_log.to_s
    sleep 3
    assert_match "Please relaunch process with admin/root privilege.", output_log.read
  ensure
    Process.kill "TERM", pid
    Process.wait pid
  end
end
