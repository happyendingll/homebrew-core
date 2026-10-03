class Sdrmm < Formula
  desc "Modular, client-server software-defined radio"
  homepage "https://github.com/Newspicel/sdrminusminus"
  url "https://github.com/Newspicel/sdrminusminus/releases/download/v2.0.0/sdrmm-2.0.0-src.tar.gz"
  sha256 "520d57e26cfea5f4f8e38905ac17f1b181f65426a457b37a565780400d59cf46"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "302204b89b668c08c0ef380b177d782e1b35d1bf1681d4b57f91b83d7cfc56cc"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "ffmpeg"

  uses_from_macos "llvm" => :build
  uses_from_macos "sqlite"

  # starts a server to test with
  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["LIBSQLITE3_SYS_USE_PKG_CONFIG"] = "1"
    system "cargo", "install", *std_cargo_args(path: "apps/sdrmm")
  end

  service do
    run [opt_bin/"sdrmm"]
    keep_alive true
    log_path var/"log/sdrmm.log"
    error_log_path var/"log/sdrmm.log"
  end

  test do
    assert_match(/\[ok\s*\] Device backends/, shell_output("#{bin}/sdrmm --doctor"))

    port = free_port
    pid = spawn bin/"sdrmm", "--bind", "127.0.0.1:#{port}"
    begin
      url = "http://127.0.0.1:#{port}"
      status = shell_output("curl -fsS --retry 30 --retry-delay 1 --retry-all-errors #{url}/api/status")
      assert_equal version.to_s, JSON.parse(status)["version"]
      assert_match '<div id="root"', shell_output("curl -fsS #{url}/")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
