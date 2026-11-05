class Typedb < Formula
  desc "Strongly-typed database with a rich and logical type system"
  homepage "https://typedb.com/"
  url "https://github.com/typedb/typedb/archive/refs/tags/3.14.2.tar.gz"
  sha256 "60ce1fe64d221be05ea7e5455f60e85f79be0b488f61bcb40266b1dfec32f1b4"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "bb3040e1cfc6f9b6ebb674e81e3b4f4223ba6b039ddbc8c1a7bb8b328e932f41"
  end

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  uses_from_macos "llvm" => :build # for libclang

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
    bin.install_symlink "typedb_server_bin" => "typedb"

    inreplace "server/config.yml" do |s|
      s.gsub!(/data-directory: .+$/, "data-directory: \"#{var}/typedb\"")
      s.gsub!(/directory: .+$/, "directory: \"#{var}/log/typedb\"")
    end
    (etc/"typedb").install "server/config.yml"
  end

  service do
    run [opt_bin/"typedb", "--config", etc/"typedb/config.yml"]
    keep_alive true
    working_dir var/"typedb"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/typedb --version")

    server_port = free_port
    log_path = testpath/"typedb.log"

    (testpath/"config.yml").write <<~YAML
      server:
        address: 0.0.0.0:#{server_port}
        http:
            enabled: false
            address: 0.0.0.0:#{free_port}
        authentication:
            token-expiration-seconds: 5000
        encryption:
            enabled: false

      storage:
          data-directory: "#{testpath}/data"

      logging:
          directory: "#{testpath}/log"
    YAML

    pid = spawn bin/"typedb", "--config", testpath/"config.yml", [:out, :err] => log_path.to_s
    sleep 5

    output = log_path.read
    assert_match "Running TypeDB", output
    assert_match(/Serving:\n\s+gRPC:\s+0.0.0.0:#{server_port}/i, output)
    assert_match "TLS: disabled", output
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
