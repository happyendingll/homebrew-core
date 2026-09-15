class Rabbitmqadmin < Formula
  desc "Command-line tool for RabbitMQ that uses the HTTP API"
  homepage "https://www.rabbitmq.com/docs/management-cli"
  url "https://github.com/rabbitmq/rabbitmqadmin-ng/archive/refs/tags/v2.35.0.tar.gz"
  sha256 "b52d5964ef296cf6a356522626a622225a825ab1248844172ace0058e211f988"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "148d3a8c6b8fbd5bf24f2ce2d72a525a9e705a4fc901850a826e7a7aecd91184"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"rabbitmqadmin", "shell", "completions", "--shell")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rabbitmqadmin --help")
    assert_match "Configuration file '~/.rabbitmqadmin.conf' does not exist",
                 shell_output("#{bin}/rabbitmqadmin config_file show 2>&1", 65)
    assert_match "error sending request for url (http://localhost:15672/api/channels)",
                 shell_output("#{bin}/rabbitmqadmin list channels 2>&1", 65)
  end
end
