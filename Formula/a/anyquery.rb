class Anyquery < Formula
  desc "Query anything with SQL"
  homepage "https://anyquery.dev"
  url "https://github.com/julien040/anyquery/archive/refs/tags/0.5.1.tar.gz"
  sha256 "cc9972f442e6df9dbf4274c641dd470ef30058dbbe78c4525c5190eab1ec4f9a"
  license "AGPL-3.0-only"
  head "https://github.com/julien040/anyquery.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "031ca8cc1eabf9c3107c74c712bc2e028a92b9de7c60e89348d747011ad55f9b"
  end

  depends_on "go" => :build
  depends_on "mysql-client" => :test

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    # TODO: Remove http2legacy once x/net >= 0.55.0: https://github.com/grpc/grpc-go/issues/9206
    tags = %w[
      vtable
      fts5
      sqlite_json
      sqlite_math_functions
      http2legacy
    ]
    system "go", "build", *std_go_args(tags:)

    generate_completions_from_executable(bin/"anyquery", shell_parameter_format: :cobra)
  end

  test do
    output = shell_output("#{bin}/anyquery -q \"SELECT * FROM non_existing_table\"")
    assert_match "no such table: non_existing_table", output

    port = free_port.to_s
    pid = spawn bin/"anyquery", "server", "--port", port
    begin
      sleep 5
      output = shell_output("#{formula_opt_bin("mysql-client")}/mysql -h 127.0.0.1 -P #{port} -e 'show tables;' main")
      assert_match "information_schema.COLLATIONS", output
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
