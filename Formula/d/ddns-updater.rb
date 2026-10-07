class DdnsUpdater < Formula
  desc "Lightweight universal DDNS Updater program"
  homepage "https://github.com/qdm12/ddns-updater"
  url "https://github.com/qdm12/ddns-updater/archive/refs/tags/v2.10.0.tar.gz"
  sha256 "809407604d35bea7615bf02292f025ad46305b384a7c55c705410b4a1c0908a6"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "7b0ee6bf8c000b3953cc98cfb7dba9bc9aaf40cbf5f629be7a6ba3e63facb91c"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/ddns-updater"
  end

  service do
    run opt_bin/"ddns-updater"
    keep_alive true
    log_path var/"log/ddns-updater.log"
    error_log_path var/"log/ddns-updater.log"
  end

  test do
    system "#{bin}/ddns-updater >log.txt & pid=$!; sleep 3; kill $pid || true"
    assert_match "INFO reading JSON config from file data/config.json", File.read(testpath/"log.txt")
    assert_match "INFO Shutdown successful", File.read(testpath/"log.txt")
    assert_match "{}", File.read(testpath/"data/config.json")
  end
end
