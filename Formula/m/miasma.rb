class Miasma < Formula
  desc "Trap AI web scrapers in an endless poison pit"
  homepage "https://github.com/austin-weeks/miasma"
  url "https://github.com/austin-weeks/miasma/archive/refs/tags/v0.4.4.tar.gz"
  sha256 "073a413fd19b695fd81b78c64e8463bc616a6c58e50e40da03e0f02d99f62a6a"
  license "GPL-3.0-or-later"
  head "https://github.com/austin-weeks/miasma.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "10b35439955984ef9dda65ecf2829e25739a294515279f9cd7217f1c0741a2b5"
  end

  depends_on "rust" => :build

  uses_from_macos "sqlite"

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    port = free_port
    pid = spawn bin/"miasma", "--host", "127.0.0.1", "--port", port.to_s

    # give the server a second to start up
    sleep 3
    system "curl", "-sSf", "http://127.0.0.1:#{port}/"
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
