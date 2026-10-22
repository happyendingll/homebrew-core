class AwsSsoCli < Formula
  desc "Securely manage AWS API credentials using AWS SSO"
  homepage "https://synfinatic.github.io/aws-sso-cli/"
  url "https://github.com/synfinatic/aws-sso-cli/archive/refs/tags/v2.3.4.tar.gz"
  sha256 "b52ef033fa140d26689234f62e7112d79f5bc5778c95ef159d15ad7164f283d6"
  license "GPL-3.0-only"
  head "https://github.com/synfinatic/aws-sso-cli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "179e8f54c6626ab8b55577b592d45d07a58382f926fd39ccb330265b690eb550"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    ldflags = %W[
      -X main.Version=#{version}
      -X main.Buildinfos=#{time.iso8601}
      -X main.Tag=#{version}
      -X main.CommitID=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"aws-sso"), "./cmd/aws-sso"

    generate_completions_from_executable(bin/"aws-sso", "setup", "completions", "--source",
                                         shell_parameter_format: :arg)
  end

  test do
    assert_match "AWS SSO CLI Version #{version}", shell_output("#{bin}/aws-sso version")
    assert_match "no AWS SSO providers have been configured",
        shell_output("#{bin}/aws-sso --config /dev/null 2>&1", 1)
  end
end
