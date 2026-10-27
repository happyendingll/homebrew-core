class Dekit < Formula
  desc "Process manager for dev and prod"
  homepage "https://dekit.run"
  url "https://github.com/pvolok/dekit/archive/refs/tags/v0.10.3.tar.gz"
  sha256 "175467fb30195c084df4bd38bf2000fad80f7e03b1e3488c29e3b114f3587ca9"
  license "MIT"
  head "https://github.com/pvolok/dekit.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "42772b96baacae021c6834c87fec67a099946e2fca54e0a3f33773b4a42adfcb"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "src")
    # `dekit` symlinked as `mprocs` runs mprocs cli
    bin.install_symlink "dekit" => "mprocs"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dekit --version")
    assert_match "Usage: mprocs", shell_output("#{bin}/mprocs --help")

    require "pty"
    begin
      r, w, pid = PTY.spawn("#{bin}/mprocs 'echo hello mprocs'")
      r.winsize = [80, 30]
      sleep 1
      w.write "qx" # q opens the quit menu, x stops everything
      assert_match "hello mprocs", r.read
    rescue Errno::EIO
      # GNU/Linux raises EIO when read is done on closed pty
    end
  ensure
    Process.kill("TERM", pid)
  end
end
