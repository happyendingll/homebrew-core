class Nats < Formula
  desc "Utility for NATS Server and JetStream administration"
  homepage "https://github.com/nats-io/natscli"
  url "https://github.com/nats-io/natscli/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "808a8905383949625e0a3f86821865eda29d381274021ff2d9ea7d7448c951fc"
  license "Apache-2.0"
  head "https://github.com/nats-io/natscli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "98359f43f012a165283b5d6aa3765ff6873dd2170763b8adcd863c3b13335dba"
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
