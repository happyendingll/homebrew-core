class Coredns < Formula
  desc "DNS server that chains plugins"
  homepage "https://coredns.io/"
  url "https://github.com/coredns/coredns/archive/refs/tags/v1.15.0.tar.gz"
  sha256 "6631fd1d6daccb6eea5a31f31cf8295080aa43c9d0683ff6680b19224c4c2d57"
  license "Apache-2.0"
  head "https://github.com/coredns/coredns.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "7801248f9e2c484178f05dde8a8d50065512d966adca61e58cdf171d4e3b57a8"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "bind" => :test # for `dig`
  end

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "make", "GOTOOLCHAIN=local"
    bin.install "coredns"
  end

  service do
    run [opt_bin/"coredns", "-conf", etc/"coredns/Corefile"]
    keep_alive true
    require_root true
    working_dir HOMEBREW_PREFIX
    log_path var/"log/coredns.log"
    error_log_path var/"log/coredns.log"
  end

  test do
    port = free_port
    spawn bin/"coredns", "-dns.port=#{port}"
    sleep(2)
    output = shell_output("dig @127.0.0.1 -p #{port} example.com.")
    assert_match(/example\.com\.\t\t0\tIN\tA\t127\.0\.0\.1\n/, output)
  end
end
