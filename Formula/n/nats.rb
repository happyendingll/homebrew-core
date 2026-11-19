class Nats < Formula
  desc "Utility for NATS Server and JetStream administration"
  homepage "https://github.com/nats-io/natscli"
  url "https://github.com/nats-io/natscli/archive/refs/tags/v0.5.2.tar.gz"
  sha256 "6a735b879a19a7abaa4b45e512f23ddb7df6e8f1cd14b32091cd8568e4e94f63"
  license "Apache-2.0"
  head "https://github.com/nats-io/natscli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "0bbe01c93229306e5434097593d171bbd8c6f9c9e466ee8e1a72cb5bcf1a3dae"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=v#{version}"), "./nats"
    generate_completions_from_executable(bin/"nats", shells:                 [:bash, :zsh],
                                                     shell_parameter_format: "--completion-script-")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nats --version")
    assert_match "No known contexts", shell_output("#{bin}/nats context ls")
    assert_match(/^[A-Z0-9]+$/, shell_output("#{bin}/nats auth nkey gen user").strip)
  end
end
