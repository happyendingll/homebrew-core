class Shpool < Formula
  desc "Persistent shell session manager"
  homepage "https://github.com/shell-pool/shpool"
  url "https://github.com/shell-pool/shpool/archive/refs/tags/v0.11.7.tar.gz"
  sha256 "a521a6fc38434c6f881145b726ad4101e4bd1dc06f6f17260fdb881b52f172b6"
  license "Apache-2.0"
  head "https://github.com/shell-pool/shpool.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "4f4afe33fd24c95b3eff0274ca07246d3b13a9303ffd60b5af1459839ea632f2"
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
    with_test_process(*args, "daemon", out: File::NULL, err: File::NULL) do
      sleep 3
      assert_predicate socket, :socket?
      sessions = JSON.parse(Utils.safe_popen_read(*args, "list", "--json")).fetch("sessions")
      assert_empty sessions
    end
  end
end
