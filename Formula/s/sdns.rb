class Sdns < Formula
  desc "Privacy important, fast, recursive dns resolver server with dnssec support"
  homepage "https://sdns.dev/"
  url "https://github.com/semihalev/sdns/archive/refs/tags/v1.9.1.tar.gz"
  sha256 "63ee0d598681965afd09b9010d1594840bc7bedf1c4386af73ac30a57eb018b5"
  license "MIT"
  head "https://github.com/semihalev/sdns.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "b8c9ecd1e3050b91d51b8c2025c51a4a71ac236a89324f50b1bbbee0ee1d7b85"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "make", "build"
    bin.install "sdns"
  end

  service do
    run [opt_bin/"sdns", "--config", etc/"sdns.conf"]
    keep_alive true
    require_root true
    error_log_path var/"log/sdns.log"
    log_path var/"log/sdns.log"
    working_dir opt_prefix
  end

  test do
    require "open3"
    stdout, = Open3.capture3(bin/"sdns", "--config", testpath/"sdns.conf", "--test")
    assert_match "Default config file generated", stdout
    assert_path_exists testpath/"sdns.conf"
  end
end
