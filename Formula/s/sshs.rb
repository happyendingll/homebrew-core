class Sshs < Formula
  desc "Graphical command-line client for SSH"
  homepage "https://github.com/quantumsheep/sshs"
  url "https://github.com/quantumsheep/sshs/archive/refs/tags/4.8.0.tar.gz"
  sha256 "d78c9a4b63fe7e1b6f4ea7de8910a28a6caa745f53a76feff59a3a580a9f6268"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "99b483f668faa14743436092cc2a4c1e3cff2d1c7f82d5e4b9327233791da7f0"
  end

  depends_on "rust" => :build
  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_equal "sshs #{version}", shell_output("#{bin}/sshs --version").strip

    (testpath/".ssh/config").write <<~EOS
      Host "Test"
        HostName example.com
        User root
        Port 22
    EOS

    require "pty"
    require "io/console"

    ENV["TERM"] = "xterm"

    PTY.spawn(bin/"sshs") do |r, w, _pid|
      r.winsize = [80, 40]
      sleep 1

      # Search for Test host
      w.write "Test"
      sleep 1

      # Quit
      w.write "\003"
      sleep 1

      begin
        r.read
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      end
    end
  end
end
