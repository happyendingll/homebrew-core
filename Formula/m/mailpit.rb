class Mailpit < Formula
  desc "Web and API based SMTP testing"
  homepage "https://mailpit.axllent.org/"
  url "https://github.com/axllent/mailpit/archive/refs/tags/v1.31.2.tar.gz"
  sha256 "397d11cc1739f8697699cbea9c58cb68a078e882871ce1bbe019abf8a5d74eb4"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "ad4aa0c2eaeb4994642e087196ca858bda0b9bbb88076bffa21fb16e984f1f4f"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  # `mailpit version` in the `test do` block checks GitHub for updates
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
    system "npm", "install", *std_npm_args(prefix: false)
  end

  def install
    system "npm", "--offline", "run", "build"

    ldflags = "-X github.com/axllent/mailpit/config.Version=v#{version}"
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"mailpit", shell_parameter_format: :cobra)
  end

  service do
    run opt_bin/"mailpit"
    keep_alive true
    log_path var/"log/mailpit.log"
    error_log_path var/"log/mailpit.log"
  end

  test do
    test_email = "wrong format message"

    output = pipe_output("#{bin}/mailpit sendmail 2>&1", test_email, 11)
    assert_match "error parsing message body: malformed header line", output

    assert_match "mailpit v#{version}", shell_output("#{bin}/mailpit version")
  end
end
