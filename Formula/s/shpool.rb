class Shpool < Formula
  desc "Persistent shell session manager"
  homepage "https://github.com/shell-pool/shpool"
  url "https://github.com/shell-pool/shpool/archive/refs/tags/v0.11.5.tar.gz"
  sha256 "171b678b38a504c2c8fa53cb8c4fcc4283fd107c12eeabd1b93d76c4a25d2087"
  license "Apache-2.0"
  head "https://github.com/shell-pool/shpool.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "11878e126513a65a150747b67f80db22b934206ed0f50711ea4f44045ed0ce4b"
  end

  depends_on "rust" => :build

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", "--locked"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "shpool")
  end

  service do
    run [opt_bin/"shpool", "daemon"]
    keep_alive true
    log_path var/"log/shpool.log"
    error_log_path var/"log/shpool.log"
  end

  test do
    socket = testpath/"shpool.socket"
    args = [bin/"shpool", "--socket", socket, "--config-file", File::NULL, "--no-daemonize"]
    pid = spawn(*args, "daemon", out: File::NULL, err: File::NULL)
    begin
      sleep 3
      assert_predicate socket, :socket?
      sessions = JSON.parse(Utils.safe_popen_read(*args, "list", "--json")).fetch("sessions")
      assert_empty sessions
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
