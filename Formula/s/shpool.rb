class Shpool < Formula
  desc "Persistent shell session manager"
  homepage "https://github.com/shell-pool/shpool"
  url "https://github.com/shell-pool/shpool/archive/refs/tags/v0.11.6.tar.gz"
  sha256 "3b8b50cc220fbd4d55f0071e8bd9aa77f035d73fb8797ae39ed883b1619d1864"
  license "Apache-2.0"
  head "https://github.com/shell-pool/shpool.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "3fd013675240fbf9e4551ce7169587dcda9e20b86beb0865515cf69bb15e7eb4"
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
